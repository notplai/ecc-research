// ─────────────────────────────────────────────────────────────
//  Elliptic Curve Cryptography — Report
//  Compile with:  typst compile ecc-report.typ
// ─────────────────────────────────────────────────────────────

// Sarabun weights as installed on macOS:
//   250 = Thin, 275 = ExtraLight, 300 = Light, 400 = Regular
// ExtraLight is 275 here (not the usual 200), so it is set explicitly.
#let body-font = "Sarabun"
#let body-weight = "extralight"
#let heading-weight = "regular"

#set document(title: "Elliptic Curve Cryptography")
#set page(paper: "a4", margin: 2.5cm)
#set text(font: body-font, weight: body-weight, size: 12pt, lang: "th")
#set par(justify: true, leading: 0.7em, spacing: 1.1em)
#set heading(numbering: "1.1")

#show heading: set text(font: body-font, weight: heading-weight, size: 14pt)
#show heading: it => {
  v(0.6em)
  it
  v(0.3em)
}

// ── Front page ───────────────────────────────────────────────

#page(margin: (top: 2cm, bottom: 2.5cm, x: 2.5cm))[
  #set align(center)
  #set text(weight: "extralight")
  #set par(justify: false, leading: 1.1em, spacing: 1.1em)

  #image("assets/Logo_of_Chulalongkorn_University_(2026).svg.webp", height: 3cm)

  #v(1.2cm)
  #text(weight: "regular")[รายงาน] \
  Elliptic Curve Cryptography

  #v(1fr)
  #text(weight: "regular")[จัดทำโดย]
  #v(0.2em)
  #grid(
    columns: (auto, auto),
    column-gutter: 2.5em,
    row-gutter: 1.1em,
    align: left,
    [นาย ประวิน หมวดสุข], [6834432623],
    [นาย ปัญญากร อินทะสมบัติ], [6834433223],
    [นาย ศุภกรณ์ คำวงษา], [6834456723],
    [นาย สรวิชญ์ นวมวัตร์], [6834458023],
  )

  #v(1fr)
  #text(weight: "regular")[เสนอ] \
  ผศ.ดร. วุฒิชัย จงจิตเมตต์

  #v(1fr)
  #text(weight: "regular")[
    รายงานนี้เป็นส่วนหนึ่งของรายวิชา 2301230 Discrete Math for CS \
    สาขาวิทยาการคอมพิวเตอร์ คณะวิทยาศาสตร์ \
    จุฬาลงกรณ์มหาวิทยาลัย
  ]
]

#counter(page).update(1)

#outline(title: [Contents], indent: auto, depth: 2)

#v(1.2em)
#outline(title: [List of Figures and Tables], target: figure)

#pagebreak()

// ── Content ──────────────────────────────────────────────────

= บทนำ

ข้อความเนื้อหาปกติใช้ฟอนต์ Sarabun ExtraLight ขนาด 12 pt
Normal body text is Sarabun ExtraLight at 12 pt.

#line(length: 100%, stroke: 0.5pt + gray)

== หัวข้อย่อย

หัวข้อทุกระดับใช้ Sarabun Regular ขนาด 14 pt