// ─────────────────────────────────────────────────────────────
//  Elliptic Curve Cryptography — Report
//  Compile with:  typst compile ecc-report.1.typ
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