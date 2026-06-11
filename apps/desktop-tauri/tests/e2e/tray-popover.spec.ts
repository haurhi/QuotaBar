import { expect, test } from "@playwright/test";

test("tray route renders a fixed-size quota popover", async ({ page }) => {
  await page.setViewportSize({ width: 680, height: 620 });
  await page.goto("/?view=tray");

  const popover = page.getByTestId("tray-popover");
  await expect(popover).toBeVisible();
  await expect(page.getByRole("heading", { name: "Quota Radar" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Settings" })).toBeVisible();

  const box = await popover.boundingBox();
  expect(box).not.toBeNull();
  expect(Math.round(box!.width)).toBe(560);
  expect(Math.round(box!.height)).toBe(500);

  await page.screenshot({ path: "tests/e2e/screenshots/tray-popover.png", fullPage: true });
});
