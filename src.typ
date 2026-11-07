// ─────────────────────────────────────────────────────────────
//  Elliptic Curve Cryptography — Report
//  Compile with:  typst compile src.typ
// ─────────────────────────────────────────────────────────────

// Sarabun weights as installed on macOS:
//   250 = Thin, 275 = ExtraLight, 300 = Light, 400 = Regular
// ExtraLight is 275 here (not the usual 200), so it is set explicitly.
#let body-font = "Sarabun"
#let body-weight = "extralight"
#let heading-weight = "regular"

#set document(title: "Elliptic Curve Cryptography")
// Page numbers as Thai letters (ก, ข, ค, …, ฮ) at the top right.
// The cover has no number; the page after it is ก.
// ฃ and ฅ are skipped as they are obsolete.
#let thai-letters = "กขคฆงจฉชซฌญฎฏฐฑฒณดตถทธนบปผฝพฟภมยรลวศษสหฬอฮ".clusters()
#let thai-page(n) = thai-letters.at(n - 1, default: str(n))

#set page(
  paper: "a4",
  margin: 2.5cm,
  // Also used by the table of contents, so its page numbers match.
  numbering: (..nums) => thai-page(nums.pos().first() - 1),
  header: context {
    if counter(page).get().first() > 1 {
      align(right, counter(page).display())
    }
  },
  footer: none,
)
#set text(font: body-font, weight: body-weight, size: 12pt, lang: "th")
#set par(
  justify: true,
  // the optimized breaker leaves stray leading spaces / splits words in Thai text
  linebreaks: "simple",
  // keep word gaps close to one space; spread the rest as slight letter spacing
  justification-limits: (
    spacing: (min: 100% * 2 / 3, max: 150%),
    tracking: (min: -0.01em, max: 0.06em),
  ),
  leading: 1.2em,
  spacing: 2.4em,
  first-line-indent: (amount: 1.5em, all: true),
)
#set heading(numbering: none)

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
  #set par(justify: false, leading: 1.1em, spacing: 1.1em, first-line-indent: 0pt)

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

#pagebreak()
// ── Introduction ──────────────────────────────────────────────────
= Introduction

#line(length: 100%, stroke: 0.5pt + gray)

 #text(weight: "regular")[Public-key cryptography] ถูกเสนอโดย Diffie และ Hellman ในปี 1976 ระบบการถอดรหัส \
ช่วยให้ทั้งสองฝ่ายที่ไม่ได้พบกันสามารถติดต่อกันได้ สามารถตกลงในการใช้ Secret Key หรือตรวจสอบ ข้อความผ่าน Open Network ความปลอดภัยของระบบนี้ขึ้นอยู่กับปัญหาทางคณิตศาสตร์ง่ายๆ แต่ แก้ย้อนกลับได้ยาก ระบบแรกๆที่นำมาใช้งานอย่างแพร่หลายคือ  #text(weight: "regular")[Diffie-Hellman Key Exchange] และ  #text(weight: "regular")[RSA] ซึ่งใช้การคำนวณแบบ Arithmetic modulo ด้วยจำนวนเต็มที่ใหญ่มาก ความปลอดภัยทั้ง สองระบบนี้ผูกติดอยู่กับความยากของ Discrete Logarithm ใน $ZZ_p^*$ ย่อมาจากคำว่า  #text(weight: "regular")[Multiplicative Group of Integers Modulo] $p$ และปัญหาแยกตัวประกอบจำนวนเต็มตามลำดับ

 ในปี 1958 มี Neal Koblitz และ Victor Miller ได้เสนอแนวคิด ในการเปลี่ยนจากการใช้ \
Multiplicative Group ของ Finite Field มาใช้ Group of Points บน Elliptic Curve แทน ข้อสังเกตสำคัญคืออัลกอริทึมที่เท่าที่รู้จักในการแก้ปัญหา Discrete Logarithm ในกลุ่มจุดบน Elliptic Cueve ทำงานได้ช้ากว่าอัลกอลิทึมที่ใช้แก้ปัญหาใน $ZZ_p^*$ (Multiplicative Group of Integers Modulo $p$) หรือแยกตัวประกอบมาก ด้วยเหตุนี้  #text(weight: "regular")[ECC (Elliptic Curve Cryptography)] จึงเข้ามาแก้ปัญหา และสามารถยกระดับความปลอดภัยได้ในระดับที่เท่ากันโดยใช้ขนาดคีย์ (Key Size) ที่เล็กกว่ามาก คีย์ของ Elliptic Curve ขนาด 256 bit ให้ครอบคุมพอๆ กับคีย์ RSA ที่มีขนาด bit ถึง 3072 bit

 ขนาด bit ที่เล็กลงหมายถึงการใช้ Bandwidth และพื้นที่จัดเก็บน้อยลง \
รวมถึงประมวลผลได้เร็วขึ้น สิ่งเหล่านี้สำคัญมากสำหรับการใช้งานบนอุปกรณ์ที่มีพื้นที่อย่างจำกัด เช่น สมาร์ตการ์ด, Embedded Controllers และโทรศัพท์ รวมถึงฝั่งเซิร์ฟเวอร์ แม้ในช่วงแรกจะมีความช้า แต่ ECC ก็ได้กลายมาเป็นตัวเลือกมาตรฐานในช่วง 2010 ในปัจจุบัน การเข้ารหัส #text(weight: "regular")[X25519] เป็น Key Exchange ที่ถูกนำมาใช้เจรจามากที่สุดใน TLS ในขณะที่ #text(weight: "regular")[Ed25519] ประเภทคีย์ที่แนะนำให้ใช้สำหรับ Secure Shell (SSH) ก็ถูกใช้ปกป้องระบบ Cryptocurrency ที่มีมูลค่าหลายแสนล้านล้าน

 เนื้อหาในส่วนฉบับนี้ถูกจัดระเบียบไว้ดังนี้ #text(weight: "regular")[ส่วนที่ 2] จะแนะนำคณิตศาสตร์ของ Elliptic Curves #text(weight: "regular")[ส่วนที่ 3] อธิบายเกี่ยวกับ Hardness assumption และการโจมตี #text(weight: "regular")[ส่วนที่ 4] นำเสนอ Protocals #text(weight: "regular")[ส่วนที่ 5] เปรียบเทียบ Standardized Curves #text(weight: "regular")[ส่วนที่ 6] ครอบคลุมเรื่องความปลอดภัย #text(weight: "regular")[ส่วนที่ 7] ตรวจสอบภัยคุกคามจากคอมพิวเตอร์ควอนตัม #text(weight: "regular")[ส่วนที่ 8] บทสรุป

#pagebreak()
// ── Contents ──────────────────────────────────────────────────

#outline(title: [Contents], indent: auto, depth: 2)

#v(1.2em)
#outline(title: [List of Figures and Tables], target: figure)

#pagebreak()
// ── Content ──────────────────────────────────────────────────



