import { expect, test } from "@playwright/test";

test("main window renders sidebar and switches between mock pages", async ({ page }) => {
  await page.goto("/");

  const nav = page.getByRole("navigation", { name: "Primary" });

  await expect(page.getByRole("heading", { name: "Quota Radar" })).toBeVisible();
  await expect(nav.getByRole("button", { name: "Quota Monitoring", exact: true })).toHaveAttribute("data-active", "true");
  await expect(page.getByRole("heading", { name: "AI Search" }).first()).toBeVisible();

  await nav.getByRole("button", { name: "Credentials", exact: true }).click();
  await expect(nav.getByRole("button", { name: "Credentials", exact: true })).toHaveAttribute("data-active", "true");
  await expect(page.getByRole("button", { name: "Add Credential" })).toBeVisible();

  await nav.getByRole("button", { name: "Diagnostics", exact: true }).click();
  await expect(page.getByRole("region", { name: "Tavily diagnostics" })).toBeVisible();
  await expect(page.getByText("HTTP 200").first()).toBeVisible();

  await nav.getByRole("button", { name: "Settings", exact: true }).click();
  await expect(page.getByText("Network proxy")).toBeVisible();
  await expect(page.getByRole("button", { name: "Customize provider order" })).toBeVisible();

  await page.screenshot({ path: "tests/e2e/screenshots/main-window.png", fullPage: true });
});

test("main window keeps sidebar and content layout separated", async ({ page }) => {
  await page.goto("/");

  const sidebarBox = await page.locator(".app-sidebar").boundingBox();
  const mainBox = await page.locator(".app-main").boundingBox();

  expect(sidebarBox).not.toBeNull();
  expect(mainBox).not.toBeNull();
  expect(mainBox!.x).toBeGreaterThanOrEqual(sidebarBox!.x + sidebarBox!.width - 1);

  for (const button of await page.locator(".sidebar-nav-item").all()) {
    const buttonBox = await button.boundingBox();
    expect(buttonBox).not.toBeNull();
    expect(buttonBox!.x).toBeGreaterThanOrEqual(sidebarBox!.x);
    expect(buttonBox!.x + buttonBox!.width).toBeLessThanOrEqual(sidebarBox!.x + sidebarBox!.width + 1);
    expect(buttonBox!.height).toBeGreaterThanOrEqual(30);
  }
});
