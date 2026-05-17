from PIL import Image, ImageDraw
import math, os

SIZE = 1024
img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# ── Rounded square background (green gradient effect via layered circles) ──────
BG = (34, 139, 74)        # rich green
BG2 = (22, 100, 52)       # darker edge
r = 200  # corner radius

def rounded_rect(d, xy, radius, fill):
    x0, y0, x1, y1 = xy
    d.rectangle([x0+radius, y0, x1-radius, y1], fill=fill)
    d.rectangle([x0, y0+radius, x1, y1-radius], fill=fill)
    d.ellipse([x0, y0, x0+2*radius, y0+2*radius], fill=fill)
    d.ellipse([x1-2*radius, y0, x1, y0+2*radius], fill=fill)
    d.ellipse([x0, y1-2*radius, x0+2*radius, y1], fill=fill)
    d.ellipse([x1-2*radius, y1-2*radius, x1, y1], fill=fill)

# Gradient simulation: paint darker base then lighter centre
rounded_rect(draw, [0, 0, SIZE, SIZE], r, BG2)
rounded_rect(draw, [40, 40, SIZE-40, SIZE-40], r-10, BG)
# subtle highlight oval at top
for i in range(60):
    alpha = int(30 * (1 - i/60))
    hl = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    hl_d = ImageDraw.Draw(hl)
    hl_d.ellipse([200+i*2, 80+i, SIZE-200-i*2, 440-i], fill=(255,255,255,alpha))
    img = Image.alpha_composite(img, hl)

draw = ImageDraw.Draw(img)

W = (255, 255, 255, 255)      # white
W2 = (220, 245, 220, 255)     # slightly tinted white for grain heads
STEM_W = 28
LEAF_W = 18

cx = SIZE // 2   # 512

# ── Main central stem ──────────────────────────────────────────────────────────
# Stem runs from bottom (y=820) to (cx, 200)
def line(x0, y0, x1, y1, width, color=W):
    draw.line([(x0, y0), (x1, y1)], fill=color, width=width)

def ellipse(x, y, w, h, color=W):
    draw.ellipse([x-w//2, y-h//2, x+w//2, y+h//2], fill=color)

# Central stem
line(cx, 820, cx, 240, STEM_W)

# ── Grain head at top — drooping to the right ─────────────────────────────────
# Main rachis curves from top of stem to the right
def curve_rachis():
    pts = []
    for t in [i/30 for i in range(31)]:
        # parametric: start (cx,240) curve to (cx+160, 480)
        x = cx + t*160
        y = 240 + t*240 + 60*t*(1-t)*(-0.5)  # slight upward bulge
        pts.append((x, y))
    return pts

rachis = curve_rachis()
for i in range(len(rachis)-1):
    draw.line([rachis[i], rachis[i+1]], fill=W, width=22)

# Grain spikelets along rachis
for i, (rx, ry) in enumerate(rachis[2:], 2):
    if i % 3 != 0:
        continue
    # perpendicular-ish direction
    dx = rachis[i][0] - rachis[i-1][0]
    dy = rachis[i][1] - rachis[i-1][1]
    length = math.hypot(dx, dy) or 1
    nx, ny = -dy/length, dx/length  # normal

    for side in [-1, 1]:
        gx = rx + side * nx * 38
        gy = ry + side * ny * 38
        # grain oval
        draw.ellipse([int(gx)-14, int(gy)-22, int(gx)+14, int(gy)+22],
                     fill=W2, outline=W, width=3)
        # stem to grain
        draw.line([(int(rx), int(ry)), (int(gx), int(gy))], fill=W, width=8)

# Left rachis (mirror drooping left)
rachis_l = [(2*cx - x, y) for x, y in rachis]
for i in range(len(rachis_l)-1):
    draw.line([rachis_l[i], rachis_l[i+1]], fill=W, width=22)
for i, (rx, ry) in enumerate(rachis_l[2:], 2):
    if i % 3 != 0:
        continue
    dx = rachis_l[i][0] - rachis_l[i-1][0]
    dy = rachis_l[i][1] - rachis_l[i-1][1]
    length = math.hypot(dx, dy) or 1
    nx, ny = -dy/length, dx/length
    for side in [-1, 1]:
        gx = rx + side * nx * 38
        gy = ry + side * ny * 38
        draw.ellipse([int(gx)-14, int(gy)-22, int(gx)+14, int(gy)+22],
                     fill=W2, outline=W, width=3)
        draw.line([(int(rx), int(ry)), (int(gx), int(gy))], fill=W, width=8)

# ── Leaves ─────────────────────────────────────────────────────────────────────
leaves = [
    # (base_y_on_stem, direction, length, angle_deg)
    (400, -1, 220, 40),   # left upper
    (400,  1, 220, 40),   # right upper
    (560, -1, 200, 35),   # left mid
    (560,  1, 200, 35),   # right mid
    (700, -1, 170, 30),   # left lower
    (700,  1, 170, 30),   # right lower
]

for (base_y, direction, length, angle) in leaves:
    rad = math.radians(angle)
    ex = cx + direction * length * math.cos(rad)
    ey = base_y - length * math.sin(rad)
    # draw curved leaf as a thick line with slight arc
    steps = 20
    pts = []
    for t in [i/steps for i in range(steps+1)]:
        # quadratic bezier: start=stem point, ctrl=midway out, end=tip
        sx, sy = cx, base_y
        # control point: halfway out, slightly raised
        ctrl_x = cx + direction * length * 0.5 * math.cos(rad)
        ctrl_y = base_y - length * 0.5 * math.sin(rad) - 30
        px = (1-t)**2 * sx + 2*(1-t)*t * ctrl_x + t**2 * ex
        py = (1-t)**2 * sy + 2*(1-t)*t * ctrl_y + t**2 * ey
        pts.append((int(px), int(py)))
    for i in range(len(pts)-1):
        w = max(4, LEAF_W - int(LEAF_W * i / len(pts)))
        draw.line([pts[i], pts[i+1]], fill=W, width=w)

# ── Soil line at base ──────────────────────────────────────────────────────────
draw.ellipse([cx-120, 800, cx+120, 850], fill=(180, 230, 180, 200))

# ── Save at all required Android mipmap sizes ──────────────────────────────────
base = r"C:\Users\user\OneDrive\Documents\demo_app\android\app\src\main\res"
sizes = {
    'mipmap-mdpi':    48,
    'mipmap-hdpi':    72,
    'mipmap-xhdpi':   96,
    'mipmap-xxhdpi':  144,
    'mipmap-xxxhdpi': 192,
}

for folder, px in sizes.items():
    out = img.resize((px, px), Image.LANCZOS)
    path = os.path.join(base, folder, 'ic_launcher.png')
    out.save(path)
    print(f"Saved {px}x{px} -> {path}")

# Also save a master 1024px for flutter_launcher_icons if needed
master_dir = r"C:\Users\user\OneDrive\Documents\demo_app\assets\icon"
os.makedirs(master_dir, exist_ok=True)
img.save(os.path.join(master_dir, 'icon.png'))
print("Saved master 1024x1024 icon")
