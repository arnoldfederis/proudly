import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { ImageResponse } from "next/og";

export const runtime = "nodejs";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

const WIDTH = 1200;
const HEIGHT = 630;
const DEVICE_WIDTH = 1419;
const DEVICE_HEIGHT = 2796;

export default async function Image() {
  const [
    iconBuffer,
    deviceBuffer,
    inter400Buffer,
    inter600Buffer,
    inter700Buffer,
  ] = await Promise.all([
    readFile(join(process.cwd(), "public", "proudly-icon-512x512.png")),
    readFile(join(process.cwd(), "public", "assets", "device-1.png")),
    readFile(join(process.cwd(), "public", "fonts", "inter-400.ttf")),
    readFile(join(process.cwd(), "public", "fonts", "inter-600.ttf")),
    readFile(join(process.cwd(), "public", "fonts", "inter-700.ttf")),
  ]);

  const iconSrc = `data:image/png;base64,${iconBuffer.toString("base64")}`;
  const deviceSrc = `data:image/png;base64,${deviceBuffer.toString("base64")}`;

  return new ImageResponse(
    <div
      style={{
        width: WIDTH,
        height: HEIGHT,
        display: "flex",
        position: "relative",
        overflow: "hidden",
        background:
          "linear-gradient(135deg, #f4efff 0%, #fdeef5 34%, #eef6ff 68%, #eefbf6 100%)",
        fontFamily: "Inter",
      }}
    >
      <div
        style={{
          position: "absolute",
          top: -120,
          left: -80,
          width: 360,
          height: 360,
          borderRadius: 999,
          background:
            "radial-gradient(circle, rgba(193, 168, 255, 0.55) 0%, rgba(193, 168, 255, 0) 72%)",
          filter: "blur(10px)",
        }}
      />
      <div
        style={{
          position: "absolute",
          right: -40,
          top: -70,
          width: 300,
          height: 300,
          borderRadius: 999,
          background:
            "radial-gradient(circle, rgba(255, 197, 224, 0.5) 0%, rgba(255, 197, 224, 0) 72%)",
          filter: "blur(8px)",
        }}
      />
      <div
        style={{
          position: "absolute",
          right: 120,
          bottom: -110,
          width: 340,
          height: 340,
          borderRadius: 999,
          background:
            "radial-gradient(circle, rgba(182, 229, 255, 0.55) 0%, rgba(182, 229, 255, 0) 72%)",
          filter: "blur(12px)",
        }}
      />

      <div
        style={{
          position: "absolute",
          inset: 34,
          display: "flex",
          borderRadius: 36,
          border: "1px solid rgba(255,255,255,0.72)",
          background: "rgba(255,255,255,0.56)",
          boxShadow:
            "0 30px 80px rgba(126, 119, 170, 0.16), inset 0 1px 0 rgba(255,255,255,0.75)",
        }}
      >
        <div
          style={{
            display: "flex",
            flex: 1,
            flexDirection: "column",
            justifyContent: "space-between",
            padding: "52px 56px",
          }}
        >
          <div style={{ display: "flex", flexDirection: "column" }}>
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 18,
                marginBottom: 34,
              }}
            >
              {/* biome-ignore lint: decorative image in OG route */}
              <img
                alt=""
                height={56}
                src={iconSrc}
                style={{
                  borderRadius: 16,
                  boxShadow: "0 12px 28px rgba(125, 111, 176, 0.18)",
                }}
                width={56}
              />
              <span
                style={{
                  color: "#44385e",
                  fontSize: 28,
                  fontWeight: 600,
                }}
              >
                Proudly
              </span>
            </div>

            <div
              style={{
                display: "flex",
                flexDirection: "column",
                color: "#241c35",
                fontSize: 64,
                fontWeight: 700,
                lineHeight: 1.03,
                letterSpacing: -2,
                maxWidth: 650,
              }}
            >
              <span>A gentle habit tracker</span>
              <span>for small wins.</span>
            </div>

            <p
              style={{
                marginTop: 28,
                maxWidth: 680,
                color: "#5b516d",
                fontSize: 30,
                lineHeight: 1.32,
                fontWeight: 400,
              }}
            >
              Build habits without pressure. Track daily wins, reminders,
              streaks, and progress with Proudly.
            </p>
          </div>

          <div
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              gap: 24,
              maxWidth: 760,
            }}
          >
            <div
              style={{
                display: "flex",
                alignItems: "center",
                padding: "14px 22px",
                borderRadius: 999,
                background: "rgba(255,255,255,0.68)",
                border: "1px solid rgba(215, 201, 245, 0.9)",
                color: "#5d4f7a",
                fontSize: 20,
                fontWeight: 600,
                boxShadow: "0 12px 30px rgba(140, 126, 181, 0.12)",
              }}
            >
              Free up to 3 habits
            </div>

            <div
              style={{
                display: "flex",
                color: "#6d617f",
                fontSize: 24,
                fontWeight: 500,
                textAlign: "right",
              }}
            >
              Do one thing today that makes you proud.
            </div>
          </div>
        </div>

        <div
          style={{
            width: 286,
            margin: "50px 24px 50px 0",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            position: "relative",
          }}
        >
          <div
            style={{
              display: "flex",
              width: 225,
              height: 438,
              borderRadius: 44,
              alignItems: "center",
              justifyContent: "center",
              background:
                "linear-gradient(180deg, rgba(255,255,255,0.84) 0%, rgba(246,241,255,0.72) 100%)",
              border: "1px solid rgba(255,255,255,0.9)",
              boxShadow:
                "0 24px 50px rgba(127, 112, 170, 0.14), inset 0 1px 0 rgba(255,255,255,0.95)",
              overflow: "hidden",
            }}
          >
            {/* biome-ignore lint: decorative image in OG route */}
            <img
              alt=""
              height={DEVICE_HEIGHT}
              src={deviceSrc}
              style={{
                width: 258,
                height: 438,
                objectFit: "contain",
                objectPosition: "center",
              }}
              width={DEVICE_WIDTH}
            />
          </div>
        </div>
      </div>
    </div>,
    {
      ...size,
      fonts: [
        { name: "Inter", data: inter400Buffer, weight: 400, style: "normal" },
        { name: "Inter", data: inter600Buffer, weight: 600, style: "normal" },
        { name: "Inter", data: inter700Buffer, weight: 700, style: "normal" },
      ],
    },
  );
}
