#!/usr/bin/env python3
"""
NegativeOS Asset Generator
Programmatically generates Win95/98-style branding assets.
Replace outputs with AI-generated artwork in a future release.

Usage:
    python3 generate-assets.py [--out /path/to/output]
"""

import argparse
import os
from PIL import Image, ImageDraw, ImageFont

# ── Win95 color palette ───────────────────────────────────────────────────────

PAL = {
    "desktop":      (0,   128, 128),   # classic teal
    "window":       (192, 192, 192),   # silver
    "titlebar":     (0,   0,   128),   # navy
    "titlebar_txt": (255, 255, 255),
    "btn_face":     (192, 192, 192),
    "btn_hi":       (255, 255, 255),   # button highlight (top/left)
    "btn_sh":       (128, 128, 128),   # button shadow (bottom/right)
    "btn_dsh":      (64,  64,  64),    # button dark shadow
    "text":         (0,   0,   0),
    "text_dim":     (128, 128, 128),
    "black":        (0,   0,   0),
    "white":        (255, 255, 255),
    "red":          (128, 0,   0),
}

def try_font(size=11):
    """Load a font, fall back to default if not found."""
    candidates = [
        "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/freefont/FreeSans.ttf",
        "/usr/share/fonts/TTF/DejaVuSans.ttf",
    ]
    for path in candidates:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()

def try_font_bold(size=11):
    candidates = [
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/freefont/FreeSansBold.ttf",
        "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
    ]
    for path in candidates:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return try_font(size)

# ── Drawing primitives ────────────────────────────────────────────────────────

def draw_raised_rect(draw, x0, y0, x1, y1, face=None):
    """Win95 raised button/panel border."""
    face = face or PAL["btn_face"]
    draw.rectangle([x0, y0, x1, y1], fill=face)
    # highlight top+left
    draw.line([x0, y0, x1, y0], fill=PAL["btn_hi"])
    draw.line([x0, y0, x0, y1], fill=PAL["btn_hi"])
    # shadow bottom+right
    draw.line([x0, y1, x1, y1], fill=PAL["btn_dsh"])
    draw.line([x1, y0, x1, y1], fill=PAL["btn_dsh"])
    draw.line([x0+1, y1-1, x1-1, y1-1], fill=PAL["btn_sh"])
    draw.line([x1-1, y0+1, x1-1, y1-1], fill=PAL["btn_sh"])

def draw_sunken_rect(draw, x0, y0, x1, y1, face=None):
    """Win95 sunken input field border."""
    face = face or PAL["white"]
    draw.rectangle([x0+2, y0+2, x1-2, y1-2], fill=face)
    draw.line([x0, y0, x1, y0], fill=PAL["btn_dsh"])
    draw.line([x0, y0, x0, y1], fill=PAL["btn_dsh"])
    draw.line([x0+1, y0+1, x1-1, y0+1], fill=PAL["btn_sh"])
    draw.line([x0+1, y0+1, x0+1, y1-1], fill=PAL["btn_sh"])
    draw.line([x0, y1, x1, y1], fill=PAL["btn_hi"])
    draw.line([x1, y0, x1, y1], fill=PAL["btn_hi"])

def draw_titlebar(draw, x0, y0, x1, h, title, font):
    """Win95 gradient-style title bar (simulated with steps)."""
    bar_h = h
    for i in range(bar_h):
        ratio = i / bar_h
        r = int(PAL["titlebar"][0] * (1 - ratio * 0.3))
        g = int(PAL["titlebar"][1] * (1 - ratio * 0.3))
        b = min(255, int(PAL["titlebar"][2] + (128 - PAL["titlebar"][2]) * ratio * 0.2))
        draw.line([x0, y0+i, x1, y0+i], fill=(r, g, b))
    # close button (X)
    cb = bar_h - 4
    cx, cy = x1 - cb - 2, y0 + 2
    draw_raised_rect(draw, cx, cy, cx+cb, cy+cb, face=PAL["btn_face"])
    draw.text((cx + cb//2 - 3, cy + 1), "✕", fill=PAL["text"], font=font)
    # title text
    draw.text((x0 + 6, y0 + (bar_h - 13)//2), title, fill=PAL["titlebar_txt"], font=font)

def draw_button(draw, x0, y0, w, h, label, font):
    draw_raised_rect(draw, x0, y0, x0+w, y0+h)
    tw, th = draw.textlength(label, font=font), 13
    draw.text((x0 + (w - tw)//2, y0 + (h - th)//2), label, fill=PAL["text"], font=font)

# ── Asset generators ──────────────────────────────────────────────────────────

def gen_wallpaper(out_dir):
    """1920x1080 teal desktop — Win95 default."""
    W, H = 1920, 1080
    img = Image.new("RGB", (W, H), PAL["desktop"])
    draw = ImageDraw.Draw(img)

    font_big  = try_font_bold(48)
    font_small = try_font(18)

    # Subtle grid pattern (very faint, like old CRT scanlines)
    for y in range(0, H, 4):
        draw.line([(0, y), (W, y)], fill=(0, 120, 120), width=1)

    # NegativeOS wordmark — bottom right, subtle
    label = "NegativeOS"
    tw = draw.textlength(label, font=font_big)
    draw.text((W - tw - 40, H - 80), label, fill=(0, 100, 100), font=font_big)
    draw.text((W - draw.textlength("Replace with AI artwork", font=font_small) - 40, H - 32),
              "Replace with AI artwork", fill=(0, 100, 100), font=font_small)

    path = os.path.join(out_dir, "wallpaper.png")
    img.save(path)
    print(f"  wallpaper.png          ({W}x{H})")
    return path

def gen_slim_background(out_dir):
    """SLiM login background — same teal as desktop."""
    W, H = 1920, 1080
    img = Image.new("RGB", (W, H), PAL["desktop"])
    draw = ImageDraw.Draw(img)
    for y in range(0, H, 4):
        draw.line([(0, y), (W, y)], fill=(0, 120, 120))
    path = os.path.join(out_dir, "background.png")
    img.save(path)
    print(f"  background.png         ({W}x{H})")
    return path

def gen_slim_panel(out_dir):
    """
    SLiM login panel — Win95 dialog box style.
    420x200px, centered dialog with username/password fields and OK button.
    SLiM overlays the actual input fields on top of this image.
    """
    W, H = 420, 220
    img = Image.new("RGB", (W, H), PAL["window"])
    draw = ImageDraw.Draw(img)

    font      = try_font(11)
    font_bold = try_font_bold(11)
    font_title = try_font_bold(12)

    # Outer raised border
    draw_raised_rect(draw, 0, 0, W-1, H-1)

    # Title bar
    TITLE_H = 22
    draw_titlebar(draw, 2, 2, W-3, TITLE_H, "NegativeOS Login", font_title)

    # Inner dialog area
    body_y = 2 + TITLE_H + 4

    # NegativeOS logo text in dialog
    logo = "NegativeOS"
    logo_font = try_font_bold(16)
    lw = draw.textlength(logo, font=logo_font)
    draw.text(((W - lw) // 2, body_y + 4), logo, fill=PAL["titlebar"], font=logo_font)

    # Username label + sunken field
    label_x = 20
    field_x  = 130
    field_w  = W - field_x - 20
    field_h  = 22

    uy = body_y + 30
    draw.text((label_x, uy + 4), "User name:", fill=PAL["text"], font=font)
    draw_sunken_rect(draw, field_x, uy, field_x + field_w, uy + field_h)

    # Password label + sunken field
    py = uy + 34
    draw.text((label_x, py + 4), "Password:", fill=PAL["text"], font=font)
    draw_sunken_rect(draw, field_x, py, field_x + field_w, py + field_h)

    # OK button
    btn_w, btn_h = 80, 24
    btn_x = (W - btn_w) // 2
    btn_y = H - btn_h - 14
    draw_button(draw, btn_x, btn_y, btn_w, btn_h, "OK", font)

    path = os.path.join(out_dir, "panel.png")
    img.save(path)
    print(f"  panel.png              ({W}x{H})  [SLiM login dialog]")
    return path

def gen_boot_splash(out_dir):
    """
    Boot splash — 800x600 framebuffer image.
    Simple teal screen with NegativeOS name and progress bar area.
    """
    W, H = 800, 600
    img = Image.new("RGB", (W, H), PAL["desktop"])
    draw = ImageDraw.Draw(img)

    font_logo  = try_font_bold(64)
    font_sub   = try_font(18)
    font_small = try_font(13)

    # Scanline texture
    for y in range(0, H, 4):
        draw.line([(0, y), (W, y)], fill=(0, 120, 120))

    # Logo
    logo = "NegativeOS"
    lw = draw.textlength(logo, font=font_logo)
    draw.text(((W - lw) // 2, H // 2 - 80), logo, fill=PAL["white"], font=font_logo)

    # Tagline
    tag = "Lean. Fast. Familiar."
    tw = draw.textlength(tag, font=font_sub)
    draw.text(((W - tw) // 2, H // 2 + 10), tag, fill=(200, 230, 230), font=font_sub)

    # Progress bar outline (Plymouth or init will fill this)
    bar_w, bar_h = 400, 18
    bar_x = (W - bar_w) // 2
    bar_y = H // 2 + 60
    draw_sunken_rect(draw, bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, face=PAL["desktop"])

    # Version
    ver = "v0.1"
    vw = draw.textlength(ver, font=font_small)
    draw.text((W - vw - 16, H - 28), ver, fill=(0, 100, 100), font=font_small)

    path = os.path.join(out_dir, "bootsplash.png")
    img.save(path)
    print(f"  bootsplash.png         ({W}x{H})  [framebuffer boot splash]")
    return path

def gen_logo_icon(out_dir):
    """
    NegativeOS logo icon — 128x128, Win95-style app icon aesthetic.
    N in a raised button square.
    """
    S = 128
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Raised square
    draw_raised_rect(draw, 0, 0, S-1, S-1, face=PAL["btn_face"])

    # Inner coloured square
    draw.rectangle([8, 8, S-9, S-9], fill=PAL["titlebar"])

    # "N" letter
    font_n = try_font_bold(80)
    tw = draw.textlength("N", font=font_n)
    draw.text(((S - tw) // 2, 14), "N", fill=PAL["white"], font=font_n)

    # Thin teal border inside the navy square
    draw.rectangle([10, 10, S-11, S-11], outline=PAL["desktop"], width=2)

    path = os.path.join(out_dir, "negativeos-logo.png")
    img.save(path)
    print(f"  negativeos-logo.png    ({S}x{S})   [app icon / window icon]")
    return path

def gen_slim_theme_readme(out_dir):
    readme = os.path.join(out_dir, "README.md")
    with open(readme, "w") as f:
        f.write("""# NegativeOS Win95 SLiM Theme

Generated programmatically. Replace with AI-generated artwork in a future release.

## Files

| File | Size | Purpose |
|------|------|---------|
| background.png | 1920x1080 | Login screen background |
| panel.png | 420x220 | Login dialog box overlay |

## Regenerating

```bash
cd NegativeOS/branding
python3 generate-assets.py
```

## Replacing with AI artwork

Drop replacement PNGs into `overlay/usr/share/slim/themes/negativeos-win95/`
and `overlay/usr/share/negativeos/wallpapers/` then rebuild.
""")

# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="NegativeOS asset generator")
    parser.add_argument("--out", default=os.path.dirname(os.path.abspath(__file__)) + "/generated",
                        help="Output directory")
    args = parser.parse_args()

    os.makedirs(args.out, exist_ok=True)

    # Resolve overlay paths relative to repo root
    repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    slim_dir  = os.path.join(repo, "overlay/usr/share/slim/themes/negativeos-win95")
    wall_dir  = os.path.join(repo, "overlay/usr/share/negativeos/wallpapers")
    pix_dir   = os.path.join(repo, "overlay/usr/share/pixmaps")
    for d in [slim_dir, wall_dir, pix_dir]:
        os.makedirs(d, exist_ok=True)

    print("NegativeOS Asset Generator")
    print("Win95/98 palette — replace with AI artwork in future release")
    print("─" * 55)

    # Generate all assets
    wp   = gen_wallpaper(args.out)
    bg   = gen_slim_background(args.out)
    pnl  = gen_slim_panel(args.out)
    spl  = gen_boot_splash(args.out)
    logo = gen_logo_icon(args.out)
    gen_slim_theme_readme(args.out)

    # Copy to overlay paths
    import shutil
    shutil.copy(bg,   os.path.join(slim_dir,  "background.png"))
    shutil.copy(pnl,  os.path.join(slim_dir,  "panel.png"))
    shutil.copy(wp,   os.path.join(wall_dir,  "wallpaper.png"))
    shutil.copy(logo, os.path.join(pix_dir,   "negativeos.png"))

    print("─" * 55)
    print(f"Assets written to: {args.out}")
    print(f"Overlay paths updated:")
    print(f"  {slim_dir}/background.png")
    print(f"  {slim_dir}/panel.png")
    print(f"  {wall_dir}/wallpaper.png")
    print(f"  {pix_dir}/negativeos.png")

if __name__ == "__main__":
    main()
