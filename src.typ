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
// Page numbers at the top right. The cover has no number.
// Front matter uses Thai letters (ก, ข, ค, …, ฮ), starting at ก after the cover;
// ฃ and ฅ are skipped as they are obsolete.
// From Mathematical Background on, pages are numbered 1, 2, 3, …
#let thai-letters = "กขคฆงจฉชซฌญฎฏฐฑฒณดตถทธนบปผฝพฟภมยรลวศษสหฬอฮ".clusters()
#let thai-page(n) = thai-letters.at(n - 1, default: str(n))

#set page(
  paper: "a4",
  margin: 2.5cm,
  // Also used by the table of contents, so its page numbers match.
  numbering: (..nums) => thai-page(nums.pos().first() - 1),
  header: context {
    if here().page() > 1 {
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
// Display equations are numbered (1), (2), … at the right.
#set math.equation(numbering: "(1)")
#show math.equation.where(block: true): set block(above: 1.2em, below: 0.8em)
// Citations: small [1], [2] on the text line, right after the word.
// The word joiner stops a line break before a citation (e.g. between [3][4]).
#show cite: it => [#sym.wj#box(super(size: 8pt, it))]

#show heading: set text(font: body-font, weight: heading-weight, size: 14pt)
// Sub-headings (==, ===, …): body size, Regular.
#show heading.where(level: 1): set text(size: 14pt)
#show heading.where(level: 2): set text(size: 12pt, weight: "regular")
#show heading.where(level: 3): set text(size: 12pt, weight: "regular")
#show heading: it => {
  v(0.6em)
  it
  v(0.3em)
}

// --- programming ────────────────────────────────────────────
#let accent = rgb("#1f4e79")
#let soft = rgb("#eef3f8")

#let defcount = counter("definition")
// Text that carries on a sentence after a display equation:
// no first-line indent and no paragraph gap above it.
#let cont(body) = block(above: 0.8em, par(first-line-indent: 0pt, body))

#let definition(name, body) = {
  defcount.step()
  block(
    width: 100%,
    fill: soft,
    inset: 10pt,
    radius: 2pt,
    stroke: (left: 2.5pt + accent),
    [*นิยามที่ #context defcount.display()* (#name). #body],
  )
}

#let real-curve-figure = {
  let f(x) = x * x * x - x + 1
  let root = -1.3247180
  let xend = 3.34
  let (xmin, xmax, ymin, ymax) = (-2.0, 3.8, -6.4, 6.4)
  let sx = 1.45cm
  let sy = 0.43cm
  let pt(x, y) = ((x - xmin) * sx, (ymax - y) * sy)

  let n = 180
  let xs = range(n + 1).map(i => root + calc.pow(i / n, 2) * (xend - root))
  let upper = xs.map(x => pt(x, calc.sqrt(calc.max(f(x), 0))))
  let lower = xs.rev().map(x => pt(x, -calc.sqrt(calc.max(f(x), 0))))
  let path-pts = lower + upper

  let dot(x, y, col) = {
    let (px, py) = pt(x, y)
    place(dx: px - 2.6pt, dy: py - 2.6pt, circle(radius: 2.6pt, fill: col, stroke: none))
  }
  let label(x, y, body, dx: 5pt, dy: -12pt) = {
    let (px, py) = pt(x, y)
    place(dx: px + dx, dy: py + dy, text(size: 9pt, body))
  }

  box(width: (xmax - xmin) * sx, height: (ymax - ymin) * sy, {
    // axes
    place(line(start: pt(xmin, 0), end: pt(xmax, 0), stroke: 0.5pt + luma(150)))
    place(line(start: pt(0, ymin), end: pt(0, ymax), stroke: 0.5pt + luma(150)))
    label(xmax, 0, $x$, dx: -8pt, dy: 2pt)
    label(0, ymax, $y$, dx: 4pt, dy: 0pt)
    // curve
    place(curve(
      stroke: 1.3pt + accent,
      curve.move(path-pts.first()),
      ..path-pts.slice(1).map(p => curve.line(p)),
    ))
    // chord through P and Q: y = 1 − 2x
    place(line(start: pt(-0.7, 2.4), end: pt(3.35, -5.7), stroke: 0.9pt + rgb("#c0392b")))
    // vertical reflection line x = 3
    place(line(start: pt(3, -5), end: pt(3, 5), stroke: (paint: luma(110), thickness: 0.7pt, dash: "dashed")))
    dot(0, 1, black)
    dot(1, -1, black)
    dot(3, -5, luma(110))
    dot(3, 5, rgb("#c0392b"))
    label(0, 1, $P$, dx: 5pt, dy: -13pt)
    label(1, -1, $Q$, dx: 6pt, dy: -4pt)
    label(3, -5, $-R$, dx: -26pt, dy: -3pt)
    label(3, 5, $R = P + Q$, dx: -62pt, dy: -6pt)
  })
}

// Tables and algorithms get their caption on top, as in the draft.
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.where(kind: "algorithm"): set figure.caption(position: top)

#let algorithm(caption, body) = figure(
  kind: "algorithm",
  supplement: [อัลกอริทึมที่],
  caption: caption,
  block(
    width: 100%,
    inset: 10pt,
    stroke: 0.7pt + black,
    {
      // compact, unindented lines inside the box; steps numbered 1. / a.
      set par(justify: false, first-line-indent: 0pt, leading: 0.8em, spacing: 0.8em)
      set enum(numbering: "1.a.")
      align(left, body)
    },
  ),
)

// Figure: all affine points of E: y² = x³ + 2x + 2 over F_17.
#let toy-points = (
  (0, 6), (0, 11), (3, 1), (3, 16), (5, 1), (5, 16), (6, 3), (6, 14), (7, 6),
  (7, 11), (9, 1), (9, 16), (10, 6), (10, 11), (13, 7), (13, 10), (16, 4), (16, 13),
)
#let finite-curve-figure = {
  let p = 17
  let c = 0.34cm
  let lab(v) = if calc.rem(v, 4) == 0 or v == 16 { text(size: 7pt, str(v)) } else { [] }
  let cells = ()
  for y in range(p).rev() {
    cells.push(align(right + horizon, lab(y)))
    for x in range(p) {
      let mark = if (x, y) == (5, 1) {
        circle(radius: 0.13cm, fill: rgb("#c0392b"))
      } else if (x, y) == (6, 3) {
        circle(radius: 0.13cm, fill: rgb("#e59866"))
      } else if toy-points.contains((x, y)) {
        circle(radius: 0.11cm, fill: accent)
      } else { [] }
      cells.push(box(width: c, height: c, stroke: 0.25pt + luma(215), align(center + horizon, mark)))
    }
  }
  cells.push([])
  for x in range(p) { cells.push(align(center, lab(x))) }
  grid(columns: (0.45cm,) + (c,) * p, column-gutter: 0pt, row-gutter: 0pt, ..cells)
}
// ── Front page ───────────────────────────────────────────────

#page(margin: (top: 2cm, bottom: 2.5cm, x: 2.5cm))[
  #set align(center)
  #set text(weight: "extralight")
  #set par(justify: false, leading: 1.1em, spacing: 1.1em, first-line-indent: 0pt)

  #image("assets/Logo_of_Chulalongkorn_University_(2026).svg", height: 3cm)

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

 #text(weight: "regular")[Public-key cryptography] ถูกเสนอโดย Diffie และ Hellman ในปี 1976@diffie1976 ระบบการถอดรหัส \
ช่วยให้ทั้งสองฝ่ายที่ไม่ได้พบกันสามารถติดต่อกันได้ สามารถตกลงในการใช้ Secret Key หรือตรวจสอบ ข้อความผ่าน Open Network ความปลอดภัยของระบบนี้ขึ้นอยู่กับปัญหาทางคณิตศาสตร์ง่ายๆ แต่ แก้ย้อนกลับได้ยาก ระบบแรกๆที่นำมาใช้งานอย่างแพร่หลายคือ  #text(weight: "regular")[Diffie-Hellman Key Exchange] และ  #text(weight: "regular")[RSA]@rsa1978 ซึ่งใช้การคำนวณแบบ Arithmetic modulo ด้วยจำนวนเต็มที่ใหญ่มาก ความปลอดภัยทั้ง สองระบบนี้ผูกติดอยู่กับความยากของ Discrete Logarithm ใน $bb(Z)_p^*$ ย่อมาจากคำว่า  #text(weight: "regular")[Multiplicative Group of Integers Modulo] $p$ และปัญหาแยกตัวประกอบจำนวนเต็มตามลำดับ

 ในปี 1958 มี Neal Koblitz และ Victor Miller ได้เสนอแนวคิด ในการเปลี่ยนจากการใช้ \
Multiplicative Group ของ Finite Field มาใช้ Group of Points บน Elliptic Curve แทน ข้อสังเกตสำคัญคืออัลกอรีทึมที่เท่าที่รู้จักในการแก้ปัญหา Discrete Logarithm ในกลุ่มจุดบน Elliptic Cueve@koblitz1987@miller1986 ทำงานได้ช้ากว่าอัลกอลิทึมที่ใช้แก้ปัญหาใน $bb(Z)_p^*$ (Multiplicative Group of Integers Modulo $p$) หรือแยกตัวประกอบมาก ด้วยเหตุนี้  #text(weight: "regular")[ECC (Elliptic Curve Cryptography)] จึงเข้ามาแก้ปัญหา และสามารถยกระดับความปลอดภัยได้ในระดับที่เท่ากันโดยใช้ขนาดคีย์ (Key Size) ที่เล็กกว่ามาก คีย์ของ Elliptic Curve ขนาด 256 bit ให้ครอบคุมพอๆ กับคีย์ RSA ที่มีขนาด bit ถึง 3072 bit

 ขนาด bit ที่เล็กลงหมายถึงการใช้ Bandwidth และพื้นที่จัดเก็บน้อยลง \
รวมถึงประมวลผลได้เร็วขึ้น สิ่งเหล่านี้สำคัญมากสำหรับการใช้งานบนอุปกรณ์ที่มีพื้นที่อย่างจำกัด เช่น สมาร์ตการ์ด, Embedded Controllers และโทรศัพท์ รวมถึงฝั่งเซิร์ฟเวอร์ แม้ในช่วงแรกจะมีความช้า แต่ ECC ก็ได้กลายมาเป็นตัวเลือกมาตรฐานในช่วง 2010 ในปัจจุบัน การเข้ารหัส #text(weight: "regular")[X25519] เป็น Key Exchange ที่ถูกนำมาใช้เจรจามากที่สุดใน TLS 1.3@rfc8446 ในขณะที่ #text(weight: "regular")[Ed25519] ประเภทคีย์ที่แนะนำให้ใช้สำหรับ Secure Shell (SSH) ก็ถูกใช้ปกป้องระบบ Cryptocurrency ที่มีมูลค่าหลายแสนล้านล้าน

 เนื้อหาในส่วนฉบับนี้ถูกจัดระเบียบไว้ดังนี้ #link(<sec:math>)[#text(weight: "regular")[ส่วนที่ 1]] จะแนะนำคณิตศาสตร์ของ Elliptic Curves #text(weight: "regular")[ส่วนที่ 2] อธิบายเกี่ยวกับ Hardness assumption และการโจมตี #text(weight: "regular")[ส่วนที่ 3] นำเสนอ Protocals #text(weight: "regular")[ส่วนที่ 4] เปรียบเทียบ Standardized Curves #text(weight: "regular")[ส่วนที่ 5] ครอบคลุมเรื่องความปลอดภัย #text(weight: "regular")[ส่วนที่ 6] ตรวจสอบภัยคุกคามจากคอมพิวเตอร์ควอนตัม #text(weight: "regular")[ส่วนที่ 7] บทสรุป

#pagebreak()
// ── Contents ──────────────────────────────────────────────────

// A normal heading (not the outline's built-in title) so Contents lists itself.
#align(center)[= สารบรรณ]

// "page" label over the page-number column; entries without dot leaders.
#block(width: 100%, below: 0.8em, align(right)[page])
#block[
  #set outline.entry(fill: none)
  #outline(title: none, indent: auto, depth: 2)
]

#v(1.2em)
// #outline(title: [List of Figures and Tables], target: figure)

// ── 1. Mathematical Background ───────────────────────────────────

// Switch to Arabic page numbers, restarting at 1 (also starts a new page).
// Reset to 0 *before* the new page: the page header reads the counter before
// any update placed on the page itself, so update(1) there would show too late.
#counter(page).update(0)
#set page(numbering: "1")
#set heading(numbering: "1.")

= Mathematical Background <sec:math>

#line(length: 100%, stroke: 0.5pt + gray)

== Finite Fields

การเข้ารหัสแบบวงรีถูกกำหนดโดย finite field $bb(F)_q$ โดยในทางปฎิบัติ ฟิลด์ดังกลาวเกือบทั้งหมดจะเป็นจำนวนเฉพาะ $bb(F)_p = {0, 1, dots, p - 1}$ ซึ่งมีการดำเนินการทางคณิตศาสตร์แบบ modulo ด้วยจำนวนเฉพาะขนาดใหญ่ $p$ ส่วนฟิลด์ฐานสอง $bb(F)_(2^m)$ นั้นเคยได้รับความนิยมในการนำไปใช้งานบนฮาร์ดแวร์ แต่มาตรฐานสมัยใหม่ส่วนใหญ่ได้เลิกสนับสนุนการใช้งานฟิลด์ประเภทนี้ไปแล้ว@sp800-186 ทั้งนี้ สมาชิกทุกตัวที่ไม่ใช่ศูนย์ใน $bb(F)_p$ จะมีตัวผกผันสำหรับการคูณซึ่งสามารถคำนวณได้โดยใช้อัลกอรีทึม Extended Euclidean หรือคำนวณจาก $a^(-1) = a^(p-2) mod p$ ตามทฤษฎีบท Fermat's little theorem

== Elliptic Curves

#definition[#text(weight: "regular")[เส้นโค้งวงรี]][ ให้ $p > 3$ เป็นจำนวนเฉพาะ เส้นโค้งวงรี $E$ บนฟิลด์ $bb(F)_p$ ในรูปแบบไวเออร์สตราสแบบย่อ (short Weierstrass form) คือเซตของคำตอบ $(x, y) in bb(F)_p^2$ ของสมการ
$ y^2 = x^3 + a x + b, quad a, b in bb(F)_p $ <eq:weierstrass>
รวมถึงจุดพิเศษที่_จุดอนันต์_ $cal(O)$ โดยเส้นโค้งดังกล่าวจะต้องไม่มีจุดเอกฐาน (non-singular) กล่าวคือ ค่าดิสคริมิแนนต์ของเส้นโค้งต้องเป็นไปตามเงื่อนไข $4a^3 + 27b^2 != 0$.
]
เงื่อนไขการไม่มีจุดเอกฐาน (non-singularity condition) รับประกันว่าเส้นโค้งจะไม่มีจุดแหลม (cusps) หรือจุดตัดตัวเอง (self-intersections) ดังนั้นจึงมีเส้นสัมผัสเพียงเส้นเดียว (unique tangent line) ที่ทุกๆจุด บนเซตของจำนวนจริงสามารถวาดเส้นโค้งนี้ได้ และภาพนี้เองที่เป็นที่มาของกฎกลุ่ม #link(<fig:real>)[(รูปที่ 1)] ส่วนบนฟีลด์จำกัด $bb(F)_p$ นั้น "เส้นโค้ง" จะเป็นเซตของจุดที่กระจัดกระจาย #link(<fig:finite>)[(รูปที่ 2)] แต่ก็ยังคงใช้สูตรพีชคณิตเดียวกันได้เสมอ
#figure(
  real-curve-figure,
  caption: [กฎคอร์ดและเส้นสัมผัส (chord-and-tangent rule) บนเส้นโค้ง $y^2 = x^3 - x + 1$ เหนือฟิลด์จำนวนจริง $bb(R)$: เส้นตรงที่ลากผ่านจุด $P = (0, 1)$ และ $Q = (1, -1)$ จะตัดกับเส้นโค้งเป็นครั้งที่สามที่จุด $-R = (3, -5)$ และเมื่อสะท้อนข้ามแกน $x$ จะได้จุดผลรวมเป็น $R = P + Q = (3, 5)$],
) <fig:real>

== The Group Law

จุดต่าง ๆ บนเส้นโค้ง $E$ ร่วมกับ $cal(O)$ ก่อตัวเป็น _อาบีเลียนกรุป (abelian group)_ ภายใต้การดำเนินการที่เขียนในรูปแบบการบวก ในทางเรขาคณิต การบวกจุดสองจุดคือ $P$ และ $Q$ ทำได้โดยการลากเส้นตรงผ่านจุดทั้งสอง เส้นตรงนี้จะตัดเส้นโค้งที่จุดอื่นอีกเพียงหนึ่งจุดเสมอ และภาพสะท้อนข้ามแกน $x$ ของจุดนั้นก็คือ $P + Q$ สำหรับการบวกจุดเดิมซ้ำสองเท่า (doubling) ให้ใช้เส้นสัมผัสแทน จุดที่อนันต์ทำหน้าที่เป็นเอกลักษณ์: $P + cal(O) = P$ และอินเวิร์สของ $P = (x, y)$ คือ $-P = (x, -y)$

เมื่อแปลงเรขาคณิตให้อยู่ในรูปพีชคณิต จะได้สูตรที่ชัดเจนดังนี้ กำหนดให้ $P = (x_1, y_1)$ และ $Q = (x_2, y_2)$ โดยที่ $P != -Q$ จะได้ $P + Q = (x_3, y_3)$ โดยที่

$ lambda = cases(
  (y_2 - y_1) / (x_2 - x_1) & "if" P != Q quad "(addition)",
  (3 x_1^2 + a) / (2 y_1) & "if" P = Q quad "(doubling)",
) $ <eq:lambda>

$ x_3 = lambda^2 - x_1 - x_2, quad quad y_3 = lambda (x_1 - x_3) - y_1. $ <eq:addition>

การดำเนินการทั้งหมดกระทำบน $bb(F)_p$ ดังนั้นการหารใน @eq:lambda จึงหมายถึงการคูณด้วยอินเวิร์สการคูณแบบมอดุลาร์ (modular inverse) หาก $P = -Q$ เส้นตรงที่ลากผ่านจะเป็นเส้นแนวตั้ง และจะได้ $P + Q = cal(O)$ ซึ่งสามารถตรวจสอบได้ว่าการดำเนินการนี้มีสมบัติการเปลี่ยนหมู่และการสลับที่ จึงทำให้ $(E(bb(F)_p), +)$ เป็นอาบีเลียนกรุปจำกัด @washington2008

#pagebreak()

== Group order and subgroups

ทฤษฎีบทของฮัสเซอ (Hasse's theorem) กำหนดขอบเขตของจำนวนจุดบนเส้นโค้งเหนือ $bb(F)_p$:

$ abs(abs(E(bb(F)_p)) - (p + 1)) <= 2 sqrt(p). $ <eq:hasse>

ดังนั้น เส้นโค้งเหนือฟีลด์ขนาด 256 บิต จะมีจุดอยู่ประมาณ $2^256$ จุด จำนวนเต็ม $t = p + 1 - abs(E(bb(F)_p))$ เรียกว่า _รอยทางของโฟรเบนิอุส (trace of Frobenius)_ โดยการนับจำนวนจุดสามารถคำนวณได้อย่างมีประสิทธิภาพด้วยขั้นตอนวิธีของชูฟ (Schoof's algorithm) และขั้นตอนวิธีที่พัฒนาต่อยอด

ระบบวิทยาการรหัสลับมักทำงานบนกรุปย่อยแบบวัฏจักรที่มีอันดับเป็นจำนวนเฉพาะขนาดใหญ่ พารามิเตอร์โดเมนมาตรฐาน (_domain parameters_) ประกอบด้วยทูเพิล $(p, a, b, G, n, h)$ ในที่นี้ $G$ คือ _จุดฐาน (base point)_ หรือตัวก่อกำเนิด (generator) ที่มีอันดับเฉพาะ $n$ ซึ่งหมายถึง $n G = cal(O)$ ส่วน _โคแฟกเตอร์ (cofactor)_ คือ $h = abs(E(bb(F)_p)) \/ n$ ซึ่งในอุดมคติควรมีค่าเป็น 1 และในทางปฏิบัติจะมีค่าน้อย (เช่น $h = 8$ สำหรับ Curve25519)

== Scalar multiplication

การดำเนินการหลักของ ECC คือการคูณสเกลาร์ กล่าวคือ เมื่อกำหนดจำนวนเต็ม $k$ และจุด $P$ ให้คำนวณ
$ k P = underbrace(P + P + dots + P, k "ครั้ง") $
#cont[การคำนวณด้วยวิธีที่ตรงไปตรงมาจะต้องอาศัยการบวกจำนวน $k - 1$ ครั้ง ซึ่งเป็นไปไม่ได้ในทางปฏิบัติเมื่อ $k approx 2^256$ ส่วนวิธี _double-and-add_ #link(<alg:dbladd>)[(อัลกอริทึมที่ 1)] จะประมวณผลจากการกระจายค่า $k$ ในรูปแบบเลขฐานสอง ซึ่งอาศัยการดำเนินงานแบบดับเบิล ประมาณ $log_2 k$ ครั้ง และการบวกอีกเพียงครึ่งหนึ่งของจำนวนดังกล่าวเท่านั้น]

#algorithm([การคูณสเกลาร์ด้วยวิธีดับเบิลแอนด์แอด (double-and-add) แบบจากซ้ายไปขวา])[
  #text(weight: "regular")[Input:] จุด $P$, สเกลาร์ $k = (k_(m-1) dots k_1 k_0)_2$ โดย $k_(m-1) = 1$ \
  #text(weight: "regular")[Output:] $Q = k P$
  + $Q <- P$
  + สำหรับ $i = m - 2$ ลดลงจนถึง $0$ ให้ทำดังนี้
    + $Q <- 2 Q$ #h(1fr) (เพิ่มสองเท่า)
    + ถ้า $k_i = 1$ ให้ $Q <- P + Q$ #h(1fr) (บวก)
  + คืนค่า $Q$
] <alg:dbladd>

การแตกแขนงตามค่า $k_i$ ส่งผลให้เวลาที่ใช้ในการประมวลผลและการใช้พลังงานขึ้นอยู่กับบิตลับค่า $k$ ดังนั้นในโค้ดที่นำไปใช้งานจริงจึงเลือกใช้วิธีที่ใช้เวลาคงที่ เช่นบันไดมอนต์โกเมอรี (Montgomery ladder)@montgomery1987 ซึ่งจะดำเนินการบวกหนึ่งครั้งและดำเนินการเพิ่มค่าเป็นสองเท่า (doubling) หนึ่งครั้งสำหรับทุกบิต โดยไม่คำนึงว่าบิตนั้นจะมีค่าเป็นเท่าใด


== A worked example over $bb(F)_17$ <sec:toy>

เพื่อให้เห็นภาพว่าคณิตศาสตร์ของ Elliptic Curve ทำงานยังไง ลองพิจารณาตัวอย่างการคำนวณสมการเส้นโค้ง $E: y^2 = x^3 + 2x + 2$ ที่ทำงานอยู่บนฟิลด์ $bb(F)_17$

- ตรวจสอบความใช้ได้ของเส้นโค้ง ต้องคำนวณค่า Discriminant ของสมการ ซึ่งเมื่อคิดเลขออกมาแล้วมีค่าเท่ากับ $4 med (mod 17)$ เนื่องจากค่านี้ไม่ได้เป็น 0 เป็นการยืนยันว่าเส้นโค้ง $E$ นี้เป็นแบบ Non-singular สามารถนำเข้ารหัสได้

#figure(
  finite-curve-figure,
  caption: [จุดทั้ง 18 จุดของ $y^2 = x^3 + 2x + 2$ เหนือฟิลด์ $bb(F)_17$ บนตารางขนาด $17 times 17$ ของ $bb(F)_17^2$ จุดฐาน $G = (5, 1)$ แสดงด้วยสีแดง และ $2G = (6, 3)$ แสดงด้วยสีส้ม],
) <fig:finite>

- การเลือกจุดเริ่มต้น 19 เป็นจำนวนเฉพาะ กฎคณิตศาสตร์บอกว่ากลุ่มตัวเลขนี้ทำงานลูป สามารถหยิบช่องไหนมาก็ได้ใน 18 ช่องเป็น "ช่องเริ่ม" เพื่อใช้สร้างช่องที่เหลือ เราเลือกช่อง $G = (5, 1)$ เป็นช่องเริ่ม (ช่องสีแดง)
- สมมาตรของกราฟ จากกราฟในรูปที่นำจุดทั้ง 18 จุดมาพล็อตบนตารางขนาด $17 times 17$ จะเห็นว่าจุดต่างๆ มีความสมมาตร พับครึ่งกันได้พอดีที่เส้นแกนกลาง $y = 8.5$ นี่เป็นผลมาจากคุณสมบัติของ Modulo 17 ที่ค่า $-(x, y)$ จะมีค่าเท่ากับ $(x, 17 - y)$ เสมอ

#text(weight: "regular")[การคำนวณหาจุดถัดไป (Doubling)] \
หากเราต้องการหาจุด $2G$ (ซึ่งคือการนำจุด $G$ มาบวกกับตัวเอง) เราจะต้องใช้สูตรทางคณิตศาสตร์เรียกว่า Doubling

+ เริ่มจากหาความชันของเส้นสัมผัส โดยแทนค่าเข้าไปในสมการคณิตศาสตร์ ซึ่งผลลัพธ์สุดท้ายจะคำนวณออกมาได้ $lambda equiv 13 med (mod 17)$
+ นำความชันที่ได้ไปคำนวณหาพิกัดใหม่ $(x_3, y_3)$ ซึ่งจะได้ $x_3 equiv 6$ และ $y_3 equiv 3 med (mod 17)$
+ ดังนั้น เราจึงได้ $2G = (6, 3)$ (ช่องสีส้มในกราฟ)

#text(weight: "regular")[วงจรการทำงานแบบสมบูรณ์ (Full cycle)] \
หากเราต้องการทำกระบวนการนี้ซ้ำไปเรื่อยๆ (เป็น $3G$, $4G$, $5G$, ...) เราจะได้พิกัดใหม่เรื่อยๆ ตาม#link(<tab:multiples>)[ตารางที่ 1] ข้อสังเกตที่น่าสนใจคือ

#figure(
  {
    // Same look as the draft: rules under the header rows only, bold header.
    set par(justify: false, first-line-indent: 0pt)
    show table.cell.where(y: 0): set text(weight: "bold")
    show table.cell.where(y: 2): set text(weight: "bold")
    table(
      columns: 10,
      align: center,
      stroke: (x, y) => if y == 0 or y == 2 { (bottom: 0.7pt + black) } else { none },
      inset: (x: 6pt, y: 4.5pt),
      table.header([$k$], [1], [2], [3], [4], [5], [6], [7], [8], [9]),
      [$k G$], [(5,1)], [(6,3)], [(10,6)], [(3,1)], [(9,16)], [(16,13)], [(0,6)], [(13,7)], [(7,6)],
      table.hline(stroke: 0.4pt + luma(180)),
      [$k$], [10], [11], [12], [13], [14], [15], [16], [17], [18],
      [$k G$], [(7,11)], [(13,10)], [(0,11)], [(16,4)], [(9,1)], [(3,16)], [(10,11)], [(6,14)], [(5,16)],
    )
  },
  caption: [ผลคูณของ $G = (5, 1)$ บน $y^2 = x^3 + 2x + 2$ เหนือฟิลด์ $bb(F)_17$ และสุดท้าย $19 G = cal(O)$],
) <tab:multiples>

พิกัดในตารางครึ่งหลัง จะเป็นภาพสะท้อนของตารางครึ่งแรกพอดีตามสมการ $k G = -(19 - k) G$ เมื่อเราบวกจุดไปเรื่อยๆ ผลลัพธ์จะหลุดเส้นและวนกลับไป "จุดอนันต์" $cal(O)$ พอดี ซึ่งถือเป็นการจบลูป


#pagebreak()
// ── 2 ECDLP ──────────────────────────────────────────────────

#pagebreak()
// ── 3 Protocols ──────────────────────────────────────────────

#pagebreak()
// ── 4 Standard curves ────────────────────────────────────────

#pagebreak()
// ── 5 Implementation ─────────────────────────────────────────

#pagebreak()
// ── 6 Quantum ────────────────────────────────────────────────

#pagebreak()
// ── 7 Conclusion ─────────────────────────────────────────────

#pagebreak(weak: true)
#bibliography("refs.bib", title: [References], style: "ieee")
