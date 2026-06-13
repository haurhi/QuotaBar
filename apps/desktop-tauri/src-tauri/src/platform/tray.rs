use std::sync::Mutex;
use std::time::{Duration, Instant};
use tauri::image::Image;
#[cfg(target_os = "linux")]
use tauri::menu::Menu;
use tauri::tray::{MouseButton, MouseButtonState, TrayIconBuilder, TrayIconEvent};
use tauri::{
    AppHandle, Manager, PhysicalPosition, Rect, Runtime, WebviewUrl, WebviewWindow,
    WebviewWindowBuilder, WindowEvent,
};
use tauri_plugin_positioner::{Position, WindowExt};

pub const TRAY_LABEL: &str = "tray";
pub const TRAY_ROUTE: &str = "/?view=tray";
pub const TRAY_WIDTH: f64 = 560.0;
pub const TRAY_HEIGHT: f64 = 500.0;
pub const TRAY_MARGIN: f64 = 12.0;
const TRAY_ICON_ID: &str = "quota-radar-tray";
const TRAY_TOOLTIP: &str = "Quota Radar";
const TRAY_CLICK_DEBOUNCE: Duration = Duration::from_millis(250);
static LAST_TRAY_TOGGLE_AT: Mutex<Option<Instant>> = Mutex::new(None);

#[derive(Debug, PartialEq)]
pub enum TrayIconSource {
    TemplateArtwork,
}

#[derive(Debug, PartialEq)]
pub struct TrayIconSpec {
    pub id: &'static str,
    pub tooltip: &'static str,
    pub title: Option<&'static str>,
    pub source: TrayIconSource,
}

#[derive(Debug, PartialEq)]
pub struct TrayWindowSpec {
    pub label: &'static str,
    pub route: &'static str,
    pub width: f64,
    pub height: f64,
    pub visible: bool,
    pub decorations: bool,
    pub resizable: bool,
    pub skip_taskbar: bool,
    pub transparent: bool,
}

#[derive(Debug, PartialEq)]
pub enum TrayToggleState {
    Show,
    Hide,
}

impl TrayToggleState {
    pub fn from_visible(is_visible: bool) -> Self {
        if is_visible {
            Self::Hide
        } else {
            Self::Show
        }
    }
}

#[derive(Debug, Clone, Copy)]
pub struct WorkArea {
    pub x: f64,
    pub y: f64,
    pub width: f64,
    pub height: f64,
}

#[derive(Debug, PartialEq)]
pub struct WindowPosition {
    pub x: f64,
    pub y: f64,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct TrayRect {
    pub x: f64,
    pub y: f64,
    pub width: f64,
    pub height: f64,
}

pub fn tray_window_spec() -> TrayWindowSpec {
    TrayWindowSpec {
        label: TRAY_LABEL,
        route: TRAY_ROUTE,
        width: TRAY_WIDTH,
        height: TRAY_HEIGHT,
        visible: false,
        decorations: false,
        resizable: false,
        skip_taskbar: true,
        transparent: true,
    }
}

pub fn tray_icon_spec() -> TrayIconSpec {
    TrayIconSpec {
        id: TRAY_ICON_ID,
        tooltip: TRAY_TOOLTIP,
        title: None,
        source: TrayIconSource::TemplateArtwork,
    }
}

pub fn menu_bar_template_icon_rgba() -> Vec<u8> {
    const SIZE: usize = 36;
    let mut rgba = vec![0; SIZE * SIZE * 4];

    for y in 0..SIZE {
        for x in 0..SIZE {
            if in_rounded_rect(x as f64 + 0.5, y as f64 + 0.5, 5.0, 5.0, 26.0, 26.0, 7.0) {
                set_pixel(&mut rgba, SIZE, x, y, 255);
            }
        }
    }

    clear_rounded_rect(&mut rgba, SIZE, 10.0, 10.0, 16.0, 15.0, 2.8);
    clear_arc(&mut rgba, SIZE, 18.0, 18.0, 5.2, 6.8, -60.0, 165.0);
    clear_arc(&mut rgba, SIZE, 18.0, 18.0, 8.3, 10.0, -45.0, 135.0);
    clear_line(&mut rgba, SIZE, 18.0, 18.0, 24.8, 13.2, 1.05);
    clear_circle(&mut rgba, SIZE, 18.0, 18.0, 1.8);

    rgba
}

fn set_pixel(rgba: &mut [u8], size: usize, x: usize, y: usize, alpha: u8) {
    let offset = (y * size + x) * 4;
    rgba[offset] = 0;
    rgba[offset + 1] = 0;
    rgba[offset + 2] = 0;
    rgba[offset + 3] = alpha;
}

fn clear_rounded_rect(
    rgba: &mut [u8],
    size: usize,
    x: f64,
    y: f64,
    width: f64,
    height: f64,
    radius: f64,
) {
    for py in 0..size {
        for px in 0..size {
            if in_rounded_rect(
                px as f64 + 0.5,
                py as f64 + 0.5,
                x,
                y,
                width,
                height,
                radius,
            ) {
                set_pixel(rgba, size, px, py, 0);
            }
        }
    }
}

fn clear_arc(
    rgba: &mut [u8],
    size: usize,
    center_x: f64,
    center_y: f64,
    inner_radius: f64,
    outer_radius: f64,
    start_degrees: f64,
    end_degrees: f64,
) {
    for y in 0..size {
        for x in 0..size {
            let dx = x as f64 + 0.5 - center_x;
            let dy = y as f64 + 0.5 - center_y;
            let radius = (dx * dx + dy * dy).sqrt();
            let angle = dy.atan2(dx).to_degrees();
            if radius >= inner_radius
                && radius <= outer_radius
                && angle >= start_degrees
                && angle <= end_degrees
            {
                set_pixel(rgba, size, x, y, 0);
            }
        }
    }
}

fn clear_line(
    rgba: &mut [u8],
    size: usize,
    start_x: f64,
    start_y: f64,
    end_x: f64,
    end_y: f64,
    radius: f64,
) {
    let dx = end_x - start_x;
    let dy = end_y - start_y;
    let length_sq = dx * dx + dy * dy;
    for y in 0..size {
        for x in 0..size {
            let px = x as f64 + 0.5;
            let py = y as f64 + 0.5;
            let t = (((px - start_x) * dx + (py - start_y) * dy) / length_sq).clamp(0.0, 1.0);
            let closest_x = start_x + t * dx;
            let closest_y = start_y + t * dy;
            let distance = ((px - closest_x).powi(2) + (py - closest_y).powi(2)).sqrt();
            if distance <= radius {
                set_pixel(rgba, size, x, y, 0);
            }
        }
    }
}

fn clear_circle(rgba: &mut [u8], size: usize, center_x: f64, center_y: f64, radius: f64) {
    for y in 0..size {
        for x in 0..size {
            let dx = x as f64 + 0.5 - center_x;
            let dy = y as f64 + 0.5 - center_y;
            if (dx * dx + dy * dy).sqrt() <= radius {
                set_pixel(rgba, size, x, y, 0);
            }
        }
    }
}

fn in_rounded_rect(px: f64, py: f64, x: f64, y: f64, width: f64, height: f64, radius: f64) -> bool {
    let right = x + width;
    let bottom = y + height;
    if px < x || px >= right || py < y || py >= bottom {
        return false;
    }

    let nearest_x = px.clamp(x + radius, right - radius);
    let nearest_y = py.clamp(y + radius, bottom - radius);
    let dx = px - nearest_x;
    let dy = py - nearest_y;
    dx * dx + dy * dy <= radius * radius
}

pub fn fallback_tray_position(
    work_area: WorkArea,
    window_width: f64,
    window_height: f64,
) -> WindowPosition {
    let x = if window_width + TRAY_MARGIN > work_area.width {
        work_area.x
    } else {
        work_area.x + work_area.width - window_width - TRAY_MARGIN
    };

    let y = if window_height + TRAY_MARGIN > work_area.height {
        work_area.y
    } else {
        work_area.y + TRAY_MARGIN
    };

    WindowPosition { x, y }
}

pub fn tray_anchor_position(
    work_area: WorkArea,
    tray_rect: TrayRect,
    window_width: f64,
    window_height: f64,
) -> WindowPosition {
    let preferred_x = tray_rect.x + tray_rect.width - window_width;
    let preferred_y = tray_rect.y + tray_rect.height + TRAY_MARGIN;

    WindowPosition {
        x: clamp_window_axis(work_area.x, work_area.width, window_width, preferred_x),
        y: clamp_window_axis(work_area.y, work_area.height, window_height, preferred_y),
    }
}

fn clamp_window_axis(area_origin: f64, area_size: f64, window_size: f64, preferred: f64) -> f64 {
    if window_size + TRAY_MARGIN > area_size {
        area_origin
    } else {
        let min = area_origin + TRAY_MARGIN;
        let max = area_origin + area_size - window_size - TRAY_MARGIN;
        preferred.clamp(min, max)
    }
}

pub fn setup_tray_shell<R: Runtime>(app: &AppHandle<R>) -> tauri::Result<()> {
    ensure_tray_window(app)?;
    ensure_tray_icon(app)?;
    Ok(())
}

fn ensure_tray_window<R: Runtime>(app: &AppHandle<R>) -> tauri::Result<()> {
    if app.get_webview_window(TRAY_LABEL).is_some() {
        return Ok(());
    }

    let spec = tray_window_spec();
    let tray_window =
        WebviewWindowBuilder::new(app, spec.label, WebviewUrl::App(spec.route.into()))
            .title("Quota Radar")
            .inner_size(spec.width, spec.height)
            .min_inner_size(spec.width, spec.height)
            .max_inner_size(spec.width, spec.height)
            .decorations(spec.decorations)
            .resizable(spec.resizable)
            .visible(spec.visible)
            .focused(false)
            .skip_taskbar(spec.skip_taskbar)
            .transparent(spec.transparent)
            .always_on_top(true)
            .shadow(true)
            .build()?;

    let window_for_blur = tray_window.clone();
    tray_window.on_window_event(move |event| {
        if matches!(event, WindowEvent::Focused(false)) {
            let _ = window_for_blur.hide();
        }
    });

    Ok(())
}

fn ensure_tray_icon<R: Runtime>(app: &AppHandle<R>) -> tauri::Result<()> {
    let spec = tray_icon_spec();
    let mut builder = TrayIconBuilder::with_id(spec.id)
        .icon(Image::new_owned(menu_bar_template_icon_rgba(), 36, 36))
        .icon_as_template(true)
        .tooltip(spec.tooltip)
        .show_menu_on_left_click(false)
        .on_tray_icon_event(|tray, event| {
            if let Some(rect) = primary_tray_click_rect(&event) {
                let _ = toggle_tray_window(tray.app_handle(), Some(rect));
            }
        });
    if let Some(title) = spec.title {
        builder = builder.title(title);
    }

    #[cfg(target_os = "linux")]
    {
        let menu = Menu::new(app)?;
        let _tray = builder.menu(&menu).build(app)?;
    }

    #[cfg(not(target_os = "linux"))]
    {
        let _tray = builder.build(app)?;
    }

    Ok(())
}

pub fn is_primary_click(button: MouseButton, button_state: MouseButtonState) -> bool {
    matches!(button, MouseButton::Left)
        && matches!(button_state, MouseButtonState::Down | MouseButtonState::Up)
}

pub fn should_accept_tray_click(last_toggle_at: Option<Instant>, now: Instant) -> bool {
    last_toggle_at
        .map(|last| now.duration_since(last) >= TRAY_CLICK_DEBOUNCE)
        .unwrap_or(true)
}

fn primary_tray_click_rect(event: &TrayIconEvent) -> Option<Rect> {
    match event {
        TrayIconEvent::Click {
            rect,
            button,
            button_state,
            ..
        } if is_primary_click(*button, *button_state) && accept_tray_click(Instant::now()) => {
            Some(*rect)
        }
        _ => None,
    }
}

fn accept_tray_click(now: Instant) -> bool {
    let mut last_toggle_at = LAST_TRAY_TOGGLE_AT
        .lock()
        .unwrap_or_else(|err| err.into_inner());
    if should_accept_tray_click(*last_toggle_at, now) {
        *last_toggle_at = Some(now);
        true
    } else {
        false
    }
}

fn toggle_tray_window<R: Runtime>(
    app: &AppHandle<R>,
    tray_rect: Option<Rect>,
) -> tauri::Result<()> {
    let window = app
        .get_webview_window(TRAY_LABEL)
        .ok_or(tauri::Error::WindowNotFound)?;

    match TrayToggleState::from_visible(window.is_visible().unwrap_or(false)) {
        TrayToggleState::Hide => window.hide(),
        TrayToggleState::Show => {
            position_tray_window(&window, tray_rect)?;
            window.show()?;
            window.set_focus()
        }
    }
}

fn position_tray_window<R: Runtime>(
    window: &WebviewWindow<R>,
    tray_rect: Option<Rect>,
) -> tauri::Result<()> {
    if let Some(rect) = tray_rect {
        if position_tray_window_near_rect(window, rect)? {
            return Ok(());
        }
    }

    if window
        .move_window_constrained(Position::TrayBottomRight)
        .is_ok()
    {
        return Ok(());
    }

    if let Some(monitor) = window
        .current_monitor()?
        .or(window.primary_monitor()?)
        .or_else(|| window.available_monitors().ok()?.into_iter().next())
    {
        let work_area = monitor.work_area();
        let window_size = window.outer_size()?;
        let position = fallback_tray_position(
            WorkArea {
                x: work_area.position.x as f64,
                y: work_area.position.y as f64,
                width: work_area.size.width as f64,
                height: work_area.size.height as f64,
            },
            window_size.width as f64,
            window_size.height as f64,
        );
        window.set_position(PhysicalPosition::new(
            position.x.round() as i32,
            position.y.round() as i32,
        ))?;
    }

    Ok(())
}

fn position_tray_window_near_rect<R: Runtime>(
    window: &WebviewWindow<R>,
    rect: Rect,
) -> tauri::Result<bool> {
    let monitors = window.available_monitors()?;
    let window_size = window.outer_size()?;

    for monitor in monitors {
        let tray_rect = tauri_rect_to_tray_rect(rect, monitor.scale_factor());
        if !monitor_contains_tray_rect(
            monitor.position().x as f64,
            monitor.position().y as f64,
            monitor.size().width as f64,
            monitor.size().height as f64,
            tray_rect,
        ) {
            continue;
        }

        let work_area = monitor.work_area();
        let position = tray_anchor_position(
            WorkArea {
                x: work_area.position.x as f64,
                y: work_area.position.y as f64,
                width: work_area.size.width as f64,
                height: work_area.size.height as f64,
            },
            tray_rect,
            window_size.width as f64,
            window_size.height as f64,
        );
        window.set_position(PhysicalPosition::new(
            position.x.round() as i32,
            position.y.round() as i32,
        ))?;
        return Ok(true);
    }

    Ok(false)
}

fn tauri_rect_to_tray_rect(rect: Rect, scale_factor: f64) -> TrayRect {
    let position = rect.position.to_physical::<f64>(scale_factor);
    let size = rect.size.to_physical::<f64>(scale_factor);

    TrayRect {
        x: position.x,
        y: position.y,
        width: size.width,
        height: size.height,
    }
}

fn monitor_contains_tray_rect(
    monitor_x: f64,
    monitor_y: f64,
    monitor_width: f64,
    monitor_height: f64,
    tray_rect: TrayRect,
) -> bool {
    let center_x = tray_rect.x + tray_rect.width / 2.0;
    let center_y = tray_rect.y + tray_rect.height / 2.0;

    center_x >= monitor_x
        && center_x <= monitor_x + monitor_width
        && center_y >= monitor_y
        && center_y <= monitor_y + monitor_height
}
