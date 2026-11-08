// ─────────────────────────────────────────────────────────────
//  Elliptic Curve Cryptography — Report
//  Compile with:  typst compile src.typ
// ─────────────────────────────────────────────────────────────

// --- Setup the documentation ─────────────────────────────────
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

#show heading: set text(font: body-font, weight: heading-weight, size: 14pt)
// Sub-headings、body size, Regular
#show heading.where(level: 1): set text(size: 14pt)
#show heading.where(level: 2): set text(size: 12pt)
#show heading.where(level: 3): set text(size: 12pt)
#show heading: it => {
  v(0.6em)
  it
  v(0.3em)
}

// Display equations are numbered (1), (2), … at the right.
#set math.equation(numbering: "(1)")
#show math.equation.where(block: true): set block(above: 1.2em, below: 0.8em)
// Citations: small [1], [2] on the text line, right after the word.
// The word joiner stops a line break before a citation (e.g. between [3][4]).
#show cite: it => [#sym.wj#box(super(size: 8pt, it))]

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

// --- programming ────────────────────────────────────────────
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
#align(center)[= คำนำ]
#v(0.3cm)
// #line(length: 100%, stroke: 0.5pt + gray)

 #text(weight: "regular")[Public-key cryptography] ถูกเสนอโดย Diffie และ Hellman ในปี 1976@diffie1976 ระบบการถอดรหัส \
ช่วยให้ทั้งสองฝ่ายที่ไม่ได้พบกันสามารถติดต่อกันได้ สามารถตกลงในการใช้ Secret Key หรือตรวจสอบ ข้อความผ่าน Open Network ความปลอดภัยของระบบนี้ขึ้นอยู่กับปัญหาทางคณิตศาสตร์ง่ายๆ แต่ แก้ย้อนกลับได้ยาก ระบบแรกๆที่นำมาใช้งานอย่างแพร่หลายคือ  #text(weight: "regular")[Diffie-Hellman Key Exchange] และ  #text(weight: "regular")[RSA]@rsa1978 ซึ่งใช้การคำนวณแบบ Arithmetic modulo ด้วยจำนวนเต็มที่ใหญ่มาก ความปลอดภัยทั้ง สองระบบนี้ผูกติดอยู่กับความยากของ Discrete Logarithm ใน $bb(Z)_p^*$ ย่อมาจากคำว่า  #text(weight: "regular")[Multiplicative Group of Integers Modulo] $p$ และปัญหาแยกตัวประกอบจำนวนเต็มตามลำดับ

 ในปี 1958 มี Neal Koblitz และ Victor Miller ได้เสนอแนวคิด ในการเปลี่ยนจากการใช้ \
Multiplicative Group ของ Finite Field มาใช้ Group of Points บน Elliptic Curve แทน ข้อสังเกตสำคัญคืออัลกอรีทึมที่เท่าที่รู้จักในการแก้ปัญหา Discrete Logarithm ในกลุ่มจุดบน Elliptic Cueve@koblitz1987@miller1986 ทำงานได้ช้ากว่าอัลกอลิทึมที่ใช้แก้ปัญหาใน $bb(Z)_p^*$ (Multiplicative Group of Integers Modulo $p$) หรือแยกตัวประกอบมาก ด้วยเหตุนี้  #text(weight: "regular")[ECC (Elliptic Curve Cryptography)] จึงเข้ามาแก้ปัญหา และสามารถยกระดับความปลอดภัยได้ในระดับที่เท่ากันโดยใช้ขนาดคีย์ (Key Size) ที่เล็กกว่ามาก คีย์ของ Elliptic Curve ขนาด 256 bit ให้ครอบคุมพอๆ กับคีย์ RSA ที่มีขนาด bit ถึง 3072 bit

 ขนาด bit ที่เล็กลงหมายถึงการใช้ Bandwidth และพื้นที่จัดเก็บน้อยลง \
รวมถึงประมวลผลได้เร็วขึ้น สิ่งเหล่านี้สำคัญมากสำหรับการใช้งานบนอุปกรณ์ที่มีพื้นที่อย่างจำกัด เช่น สมาร์ตการ์ด, Embedded Controllers และโทรศัพท์ รวมถึงฝั่งเซิร์ฟเวอร์ แม้ในช่วงแรกจะมีความช้า แต่ ECC ก็ได้กลายมาเป็นตัวเลือกมาตรฐานในช่วง 2010 ในปัจจุบัน การเข้ารหัส #text(weight: "regular")[X25519] เป็น Key Exchange ที่ถูกนำมาใช้เจรจามากที่สุดใน TLS 1.3@rfc8446 ในขณะที่ #text(weight: "regular")[Ed25519] ประเภทคีย์ที่แนะนำให้ใช้สำหรับ Secure Shell (SSH) ก็ถูกใช้ปกป้องระบบ Cryptocurrency ที่มีมูลค่าหลายแสนล้านล้าน

 เนื้อหาในส่วนฉบับนี้ถูกจัดระเบียบไว้ดังนี้ #link(<sec:math>)[#text(weight: "regular")[ส่วนที่ 1]] จะแนะนำคณิตศาสตร์ของ Elliptic Curves #link(<sec:ecdlp>)[#text(weight: "regular")[ส่วนที่ 2]] อธิบายเกี่ยวกับ Hardness assumption และการโจมตี #link(<sec:protocols>)[#text(weight: "regular")[ส่วนที่ 3]] นำเสนอ Protocals \
 #link(<sec:curves>)[#text(weight: "regular")[ส่วนที่ 4]] เปรียบเทียบ Standardized Curves #link(<sec:impl>)[#text(weight: "regular")[ส่วนที่ 5]] ครอบคลุมเรื่องความปลอดภัย \
#link(<sec:quantum>)[#text(weight: "regular")[ส่วนที่ 6]] ตรวจสอบภัยคุกคามจากคอมพิวเตอร์ควอนตัม #link(<sec:conclusion>)[#text(weight: "regular")[ส่วนที่ 7]] บทสรุป

#pagebreak()
// ── Contents ──────────────────────────────────────────────────

// A normal heading (not the outline's built-in title) so Contents lists itself.
#align(center)[= สารบรรณ]
#v(0.3cm)

// "page" label over the page-number column; entries without dot leaders.
#block(width: 100%, below: 0.8em, align(right)[หน้า])
#block[
  #set outline.entry(fill: none)
  #outline(title: none, indent: auto, depth: 2)
]

// #v(1.2em)
// #outline(title: [List of Figures and Tables], target: figure)

#pagebreak()
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
รวมถึงจุดพิเศษที่_จุดอนันต์_ $cal(O)$ โดยเส้นโค้งดังกล่าวจะต้องไม่มีจุดเอกฐาน กล่าวคือ ค่าดิสคริมิแนนต์ของเส้นโค้งต้องเป็นไปตามเงื่อนไข $4a^3 + 27b^2 != 0$.
]
เงื่อนไขการไม่มีจุดเอกฐาน รับประกันว่าเส้นโค้งจะไม่มีจุดแหลมหรือจุดตัดตัวเอง ดังนั้นจึงมีเส้นสัมผัสเพียงเส้นเดียวที่ทุกๆจุด บนเซตของจำนวนจริงสามารถวาดเส้นโค้งนี้ได้ และภาพนี้เองที่เป็นที่มาของกฎกลุ่ม #link(<fig:real>)[(รูปที่ 1)] ส่วนบนฟีลด์จำกัด $bb(F)_p$ นั้น "เส้นโค้ง" จะเป็นเซตของจุดที่กระจัดกระจาย #link(<fig:finite>)[(รูปที่ 2)] แต่ก็ยังคงใช้สูตรพีชคณิตเดียวกันได้เสมอ
#figure(
  real-curve-figure,
  caption: [กฎคอร์ดและเส้นสัมผัส บนเส้นโค้ง $y^2 = x^3 - x + 1$ เหนือฟิลด์จำนวนจริง $bb(R)$: เส้นตรงที่ลากผ่านจุด $P = (0, 1)$ และ $Q = (1, -1)$ จะตัดกับเส้นโค้งเป็นครั้งที่สามที่จุด $-R = (3, -5)$ และเมื่อสะท้อนข้ามแกน $x$ จะได้จุดผลรวมเป็น $R = P + Q = (3, 5)$],
) <fig:real>

== The Group Law

จุดต่าง ๆ บนเส้นโค้ง $E$ ร่วมกับ $cal(O)$ ก่อตัวเป็น _อาบีเลียนกรุป (abelian group)_ ภายใต้การดำเนินการที่เขียนในรูปแบบการบวก ในทางเรขาคณิต การบวกจุดสองจุดคือ $P$ และ $Q$ ทำได้โดยการลากเส้นตรงผ่านจุดทั้งสอง เส้นตรงนี้จะตัดเส้นโค้งที่จุดอื่นอีกเพียงหนึ่งจุดเสมอ และภาพสะท้อนข้ามแกน $x$ ของจุดนั้นก็คือ $P + Q$ สำหรับการบวกจุดเดิมซ้ำสองเท่า ให้ใช้เส้นสัมผัสแทน จุดที่อนันต์ทำหน้าที่เป็นเอกลักษณ์: $P + cal(O) = P$ และอินเวิร์สของ $P = (x, y)$ คือ $-P = (x, -y)$

เมื่อแปลงเรขาคณิตให้อยู่ในรูปพีชคณิต จะได้สูตรที่ชัดเจนดังนี้ กำหนดให้ $P = (x_1, y_1)$ และ $Q = (x_2, y_2)$ โดยที่ $P != -Q$ จะได้ $P + Q = (x_3, y_3)$ โดยที่

$ lambda = cases(
  (y_2 - y_1) / (x_2 - x_1) & "if" P != Q quad "(addition)",
  (3 x_1^2 + a) / (2 y_1) & "if" P = Q quad "(doubling)",
) $ <eq:lambda>

$ x_3 = lambda^2 - x_1 - x_2, quad quad y_3 = lambda (x_1 - x_3) - y_1. $ <eq:addition>

การดำเนินการทั้งหมดกระทำบน $bb(F)_p$ ดังนั้นการหารใน @eq:lambda จึงหมายถึงการคูณด้วยอินเวิร์สการคูณแบบมอดุลาร์หาก $P = -Q$ เส้นตรงที่ลากผ่านจะเป็นเส้นแนวตั้ง และจะได้ $P + Q = cal(O)$ ซึ่งสามารถตรวจสอบได้ว่าการดำเนินการนี้มีสมบัติการเปลี่ยนหมู่และการสลับที่ จึงทำให้ $(E(bb(F)_p), +)$ เป็นอาบีเลียนกรุปจำกัด@washington2008

#pagebreak()

== Group order and subgroups

ทฤษฎีบทของฮัสเซอ (Hasse's theorem) กำหนดขอบเขตของจำนวนจุดบนเส้นโค้งเหนือ $bb(F)_p$:

$ abs(abs(E(bb(F)_p)) - (p + 1)) <= 2 sqrt(p). $ <eq:hasse>

ดังนั้น เส้นโค้งเหนือฟีลด์ขนาด 256 บิต จะมีจุดอยู่ประมาณ $2^256$ จุด จำนวนเต็ม $t = p + 1 - abs(E(bb(F)_p))$ เรียกว่า _รอยทางของโฟรเบนิอุส (trace of Frobenius)_ โดยการนับจำนวนจุดสามารถคำนวณได้อย่างมีประสิทธิภาพด้วยขั้นตอนวิธีของชูฟ (Schoof's algorithm) และขั้นตอนวิธีที่พัฒนาต่อยอด

ระบบวิทยาการรหัสลับมักทำงานบนกรุปย่อยแบบวัฏจักรที่มีอันดับเป็นจำนวนเฉพาะขนาดใหญ่ พารามิเตอร์โดเมนมาตรฐาน (_domain parameters_) ประกอบด้วยทูเพิล $(p, a, b, G, n, h)$ ในที่นี้ $G$ คือ _จุดฐาน (base point)_ หรือตัวก่อกำเนิดที่มีอันดับเฉพาะ $n$ ซึ่งหมายถึง $n G = cal(O)$ ส่วน _โคแฟกเตอร์ (cofactor)_ คือ $h = abs(E(bb(F)_p)) \/ n$ ซึ่งในอุดมคติควรมีค่าเป็น 1 และในทางปฏิบัติจะมีค่าน้อย (เช่น $h = 8$ สำหรับ Curve25519)

== Scalar multiplication

การดำเนินการหลักของ ECC คือการคูณสเกลาร์ กล่าวคือ เมื่อกำหนดจำนวนเต็ม $k$ และจุด $P$ ให้คำนวณ
$ k P = underbrace(P + P + dots + P, k "ครั้ง") $
#cont[การคำนวณด้วยวิธีที่ตรงไปตรงมาจะต้องอาศัยการบวกจำนวน $k - 1$ ครั้ง ซึ่งเป็นไปไม่ได้ในทางปฏิบัติเมื่อ $k approx 2^256$ ส่วนวิธี _double-and-add_ #link(<alg:dbladd>)[(อัลกอริทึมที่ 1)] จะประมวณผลจากการกระจายค่า　$k$　ในรูปแบบเลขฐานสอง ซึ่งอาศัยการดำเนินงานแบบดับเบิล ประมาณ $log_2 k$ ครั้ง และการบวกอีกเพียงครึ่งหนึ่งของจำนวนดังกล่าวเท่านั้น]

#algorithm([การคูณสเกลาร์ด้วยวิธีดับเบิลแอนด์แอด (double-and-add) แบบจากซ้ายไปขวา])[
  #text(weight: "regular")[Input:] จุด $P$, สเกลาร์ $k = (k_(m-1) dots k_1 k_0)_2$ โดย $k_(m-1) = 1$ \
  #text(weight: "regular")[Output:] $Q = k P$
  + $Q <- P$
  + สำหรับ $i = m - 2$ ลดลงจนถึง $0$ ให้ทำดังนี้
    + $Q <- 2 Q$ #h(1fr) (doubling)
    + ถ้า $k_i = 1$ ให้ $Q <- P + Q$ #h(1fr) (addition)
  + คืนค่า $Q$
] <alg:dbladd>

การแตกแขนงตามค่า $k_i$ ส่งผลให้เวลาที่ใช้ในการประมวลผลและการใช้พลังงานขึ้นอยู่กับบิตลับค่า $k$ ดังนั้นในโค้ดที่นำไปใช้งานจริงจึงเลือกใช้วิธีที่ใช้เวลาคงที่ เช่นบันไดมอนต์โกเมอรี (Montgomery ladder)@montgomery1987 ซึ่งจะดำเนินการบวกหนึ่งครั้งและดำเนินการเพิ่มค่าเป็นสองเท่า หนึ่งครั้งสำหรับทุกบิต โดยไม่คำนึงว่าบิตนั้นจะมีค่าเป็นเท่าใด


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

// ── 2 ECDLP ──────────────────────────────────────────────────

= The Elliptic Curve Discrete Logarithm Problem <sec:ecdlp>

#line(length: 100%, stroke: 0.5pt + gray)

#definition[#text(weight: "regular")[ECDLP]][ กำหนดให้มีพารามิเตอร์โดเมนพร้อมด้วยจุดฐาน $G$ เป็นอันดับจำนวนเฉพาะ $n$ และจุด $Q in chevron.l G chevron.r$ จงหาจำนวนเต็ม $k in [0, n - 1]$ ที่ทำให้ $Q = k G$
]

การคูณสเกลาร์เป็นฟังก์ชั่นทางเดียว การคำนวน $Q = k G$ ใช้เวลาเพียงระดับไมโครวินาที แต่การหาค่า $k$ คืนจาก $Q$ ดูเหมือนจะเป็นไปไม่ได้ในทางปฏิบัติหากเลือกเส้นโค้งไว้อย่างอย่างเหมาะสม ในตัวอย่างจำลองการหาค่า $k$ ที่ทำให้ $k G = (16, 4)$ นั้นทำได้ง่าย เพราะอ่านได้จาก#link(<tab:multiples>)[ตารางที่ 1] ว่า $k = 13$ แต่เมื่อ $n approx 2^256$ จะไม่สามารถสร้างตารางหรือใช้วิธีค้นหาแบบไล่เลียงทุกกรณีได้เลย

#pagebreak()
== Generic Attacks

อัลกอริทึมที่รู้จักกันดีที่สุดสำหรับ ECDLP บนเส้นโค้งที่เลือกไว้อย่างดีนั้นเป็นแบบทั่วไป พวกมันใช้เพียงการดำเนินการกลุ่มและจะทำงานได้ในกลุ่มใดก็ได้ วิธีที่ใช้งานได้จริงที่สุดคือวิธี rho ของ Pollard@pollard1978 ซึ่งหาการชนกัน ในการเดินสุ่มเทียม ในเวลาประมาณ
$ sqrt((pi n) / 4) approx 0.886 sqrt(n) $
#cont[การดำเนินการในกลุ่ม ใช้หน่วยความจำน้อยมาก วิธีการขนานแบบ Van Oorschot–Wiener ช่วยให้ความเร็วเพิ่มขึ้นเป็นสัดส่วนเชิงเส้นตามจำนวนหน่วยประมวลผล ส่วนอัลกอริทึม Pohlig–Hellman จะลดทอนปัญหาลงเหลือเพียงการพิจารณาตัวประกอบเฉพาะที่มีค่ามากที่สุดของ $n$ ด้วยเหตุนี้ $n$ จึงจำเป็นต้องเป็นจำนวนเฉพาะที่มีค่ามาก โดยสรุปแล้ว เส้นโค้งที่มีกลุ่มย่อย ซึ่งมีอันดับเป็นจำนวนเฉพาะขนาด $2b$ บิต จะให้ระดับความปลอดภัยประมาณ $b$ บิต]

นี่คือที่มาหลักของประสิทธิภาพใน ECC สำหรับกลุ่มปัญหาที่เกี่ยวข้องกับ $bb(Z)_p^*$ และการแยกตัวประกอบจำนวนเต็ม อัลกอริทึมในตระกูล index calculus และ number field sieve มีเวลาการทำงานในระดับ sub-exponential ด้วยเหตุนี้ ขนาดของกุญแจจึงจำเป็นต้องเพิ่มขึ้นในอัตราที่เร็วกว่าแบบเชิงเส้น เมื่อระดับความปลอดภัยสูงขึ้น ในขณะที่ยังไม่มีอัลกอริทึมในลักษณะเดียวกันนี้สำหรับเส้นโค้งวงรีทั่วไปบนฟิลด์จำนวนเฉพาะ #link(<tab:keysizes>)[ตารางที่ 2] แสดงให้เห็นถึงช่องว่างดังกล่าว โดยอ้างอิงตามเกณฑ์ความเท่าเทียมกันของขนาดกุญแจที่กำหนดโดย NIST@sp800-57

#figure(
  {
    // Same look as the draft: a rule under the header row only, bold header.
    set par(justify: false, first-line-indent: 0pt)
    show table.cell.where(y: 0): set text(weight: "bold")
    table(
      columns: (auto, auto, auto, auto, auto),
      align: (center, left, right, right, right),
      stroke: (x, y) => if y == 0 { (bottom: 0.7pt + black) } else { none },
      inset: (x: 6pt, y: 4.5pt),
      table.header([Security (bits)], [Symmetric], [RSA / DH modulus], [ECC key size], [Ratio]),
      [80], [2TDEA], [1024], [160–223], [6 : 1],
      [112], [3TDEA], [2048], [224–255], [9 : 1],
      [128], [AES-128], [3072], [256–383], [12 : 1],
      [192], [AES-192], [7680], [384–511], [20 : 1],
      [256], [AES-256], [15360], [512+], [30 : 1],
    )
  },
  caption: [ขนาดกุญแจที่ให้ความปลอดภัยเทียบเท่ากัน ตามเกณฑ์ของ NIST SP 800-57 โดยอัตราส่วนเปรียบเทียบขนาด RSA modulus กับขนาดกุญแจ ECC ที่เล็กที่สุดที่ให้ความปลอดภัยเท่ากัน],
) <tab:keysizes>

#pagebreak()

== Weak Curves

เส้นโค้งบางประเภทมีความเสี่ยงต่อการถูกโจมตีด้วยวิธีที่รวดเร็วกว่าปกติมาก จึงควรหลีกเลี่ยงการใช้งานได้แก่

- #text(weight: "regular")[เส้นโค้ง Supersingular และเส้นโค้งที่มี Embedding degree ต่ำ] \
  การโจมตีแบบ MOV@mov1993 จะใช้ Weil pairing หรือ Tate pairing เพื่อแปลงปัญหา ECDLP ไปสู่ปัญหา Discrete logarithm ในฟิลด์ขยาย $bb(F)_(p^k)$ ซึ่งหากค่า Embedding degree $k$ มีขนาดเล็ก จะสามารถใช้วิธี Index calculus ที่มีความซับซ้อนในระดับต่ำกว่าเอกซ์โพเนนเชียล ในการแก้ปัญหาได้ (ทั้งนี้ เส้นโค้งประเภท Pairing-friendly ถูกออกแบบมาให้มีค่า $k$ ขนาดเล็กโดยเจตนาเพื่อวัตถุประสงค์เฉพาะ โดยจะมีการกำหนดพารามิเตอร์อื่นให้มีขนาดใหญ่ขึ้น)
- #text(weight: "regular")[เส้นโค้ง Anomalous] \
  หากจำนวนจุดบนเส้นโค้ง $abs(E(bb(F)_p))$ เท่ากับ $p$ (นั่นคือค่า Trace $t = 1$) ปัญหา ECDLP จะสามารถแก้ไขได้ภายในเวลาที่เป็นพหุนาม โดยใช้เทคนิค $p$-adic lifting@smart1999
- #text(weight: "regular")[เส้นโค้งบนฟิลด์ขยายที่มีดีกรีเป็นจำนวนประกอบ] \
  เส้นโค้งประเภทนี้มีความเสี่ยงต่อการถูกโจมตีแบบ Weil descent และ summation-polynomial
- #text(weight: "regular")[เส้นโค้งที่มีลำดับของกลุ่มเป็นจำนวนที่แยกตัวประกอบได้ง่าย] \
  เส้นโค้งประเภทนี้สามารถถูกถอดรหัสได้ด้วยอัลกอริทึมของ Pohlig–Hellman

ในการกำหนดเส้นโค้งมาตรฐานจะมีการคัดเลือกโดยหลีกเลี่ยงลักษณะที่ไม่ปลอดภัยเหล่านี้ทั้งหมด นอกจากนี้ โครงการ SafeCurves@safecurves ยังได้ขยายเกณฑ์การพิจารณาเพิ่มเติม โดยครอบคลุมถึงความปลอดภัยในขั้นตอนการนำไปใช้งานจริง นอกเหนือไปจากความปลอดภัยของปัญหา ECDLP เพียงอย่างเดียว

#pagebreak()
// ── 3 Protocols ──────────────────────────────────────────────

= Cryptographic Protocols <sec:protocols>

#line(length: 100%, stroke: 0.5pt + gray)

ในกรณีทั้งหมดต่อไปนี้ กุญแจส่วนตัวของผู้ใช้คือจำนวนเต็มสุ่ม $d in [1, n - 1]$ และกุญแจสาธารณะที่สอดคล้องกันคือจุด $Q = d G$

== Elliptic Curve Diffie–Hellman (ECDH)

ECDH ช่วยให้คู่สนทนาสองฝ่ายสามารถสร้างความลับร่วมกันผ่านช่องทางสาธารณะได้ โดยกระบวนการแลกเปลี่ยนดังกล่าวแสดงไว้ใน#link(<fig:ecdh>)[รูปที่ 3]

#figure(
  block(width: 100%, inset: 10pt, stroke: 0.7pt + black, {
    set par(justify: false, first-line-indent: 0pt)
    grid(
      columns: (1fr, 1.1fr, 1fr),
      row-gutter: 0.9em,
      align: (left, center, right),
      text(weight: "regular")[Alice], text(weight: "regular")[ช่องทางสาธารณะ], text(weight: "regular")[Bob],
      [pick random $a in [1, n - 1]$], [], [pick random $b in [1, n - 1]$],
      [$A = a G$], [$A$ #h(0.3em) $arrow.long.r$ \ $arrow.long.l$ #h(0.3em) $B$], [$B = b G$],
      [$S = a B$], [], [$S = b A$],
      grid.cell(colspan: 3, align: center)[$a B = a (b G) = (a b) G = b (a G) = b A$],
      grid.cell(colspan: 3, align: center)[session key $= "KDF"(x_S)$],
    )
  }),
  caption: [การตกลงกุญแจร่วมกันแบบ Elliptic Curve Diffie–Hellman],
) <fig:ecdh>

ผู้ดักฟังจะเห็นค่า $G$, $A$ และ $B$ จะต้องคำนวณหาค่า $a b G$ ให้ได้ ปัญหานี้เรียกว่าปัญหาการคำนวณแบบดิฟฟี-เฮลล์แมนซึ่งเชื่อกันว่ามีความยากเทียบเท่ากับปัญหาลอการิทึมไม่ต่อเนื่องบนเส้นโค้งวงรี สำหรับเส้นโค้งมาตรฐาน โดยจุดที่ได้ร่วมกันนั้นจะไม่มีการนำไปใช้งานโดยตรง แต่จะนำค่าพิกัด $x$ ของจุดดังกล่าวไปผ่านฟังก์ชั่นสร้างกุญแจ

ในกลุ่มตัวอย่างนี้ หาก Alice เลือก $a = 3$ จะได้ $A = (10, 6)$ และหาก Bob เลือก $b = 7$ จะได้ $B = (0, 6)$ ทั้งสองฝ่ายจะได้ค่า $S = 21 G = 2 G = (6, 3)$

เนื่องจาก ECDH แบบปกติไม่มีกลไกการยืนยันตัวตน ผู้โจมตีแบบเชิงรุกจึงอาจแทรกตัวอยู่ระหว่าง Alice และ Bob ได้ ในทางปฏิบัติ ค่าสาธารณะจะถูกลงนามกำกับไว้ (เช่น ในโปรโตคอล TLS) หรือผูกไว้กับกุญแจระบุตัวตนระยะยาว (เช่น ในโปรโตคอล X3DH ของ Signal) การใช้กุญแจชั่วคราวที่สร้างขึ้นใหม่สำหรับทุกเซสชันจะช่วยให้เกิดคุณสมบัติความลับแบบส่งต่อ ซึ่งหมายความว่าหากกุญแจระยะยาวถูกบุกรุกในภายหลัง ข้อมูลของเซสชันที่ผ่านมาก็จะไม่ถูกเปิดเผย ทั้งนี้ โปรโตคอล TLS 1.3 กำหนดให้ต้องมีการแลกเปลี่ยนกุญแจชั่วคราวสำหรับการสร้างการเชื่อมต่อทุกครั้งที่ไม่ได้เป็นการกลับมาเชื่อมต่อใหม่@rfc8446

== Elliptic Curve Digital Signature Algorithm (ECDSA)

ECDSA ถูกกำหนดมาตรฐานไว้ใน FIPS 186@fips186-5 เป็นอัลกอริทึมที่พัฒนาต่อยอดมาจาก DSA โดยใช้หลักการของเส้นโค้งวงรี กำหนดให้ $H$ เป็นฟังก์ชั่นแฮชเชิงรหัสลับ และให้ $z$ คือค่าที่ได้จากบิตทางซ้ายสุดจำนวน $ceil(log_2 n)$ บิต ของผลลัพธ์จากฟังก์ชั่นแฮช $H(m)$ สำหรับข้อความ $m$ ใดๆ

#algorithm([การสร้างและการตรวจสอบลายเซ็นดิจิทัลแบบ ECDSA])[#text(size: 10pt)[
  #text(weight: "regular")[การสร้างลายเซ็น] $(d, m)$:
  + เลือกค่าสุ่ม $k in [1, n - 1]$ ขึ้นมาใหม่ โดยให้เป็นค่าความลับและสุ่มแบบกระจายตัวสม่ำเสมอ
  + คำนวณหา $(x_1, y_1) = k G$ และกำหนดให้ $r = x_1 mod n$ หาก $r = 0$ ให้ย้อนกลับไปทำขั้นตอนที่ 1 ใหม่
  + คำนวณหา $s = k^(-1) (z + r d) mod n$ หาก $s = 0$ ให้ย้อนกลับไปทำขั้นตอนที่ 1 ใหม่
  + ส่งผลลัพธ์เป็นลายเซ็น $(r, s)$

  #text(weight: "regular")[การตรวจสอบลายเซ็น] $(Q, m, (r, s))$:
  + ตรวจสอบว่า $r, s in [1, n - 1]$ และ $Q$ เป็นจุดที่ถูกต้องบนเส้นโค้งซึ่งมีอันดับ (order) เท่ากับ $n$
  + คำนวณหา $w = s^(-1) mod n$, $u_1 = z w mod n$ และ $u_2 = r w mod n$
  + คำนวณหา $(x_1, y_1) = u_1 G + u_2 Q$ หากผลลัพธ์ที่ได้คือจุดอนันต์ ($cal(O)$) ให้ปฏิเสธลายเซ็นนี้
  + ยอมรับลายเซ็นก็ต่อเมื่อ $r equiv x_1 med (mod n)$ เท่านั้น
  ]
] <alg:ecdsa>

ความถูกต้องเป็นผลมาจาก $u_1 G + u_2 Q = s^(-1) (z + r d) G = k G$

#block(width: 100%, inset: 10pt, stroke: 0.7pt + black, breakable: false, {
  set par(first-line-indent: 0pt)
  [#text(size: 10pt)[ค่า nonce จะต้องถูกเก็บเป็นความลับและห้ามนำกลับมาใช้ซ้ำเด็ดขาด หากลายเซ็นสองลายเซ็น $(r, s_1)$ และ $(r, s_2)$ ในข้อความที่แตกต่างกันใช้ nonce $k$ ร่วมกัน (ซึ่งมองเห็นได้เป็น $r$ ที่เท่ากัน) ใครก็ตามก็สามารถกู้คืนคีย์ส่วนตัวได้:]
  $ k = (z_1 - z_2) / (s_1 - s_2) mod n, quad quad d = (s_1 k - z_1) / r mod n $
  #text(size: 10pt)[นี่คือวิธีเดียวกับที่คีย์สำหรับลงนามโค้ด ของ PlayStation 3 ถูกดึงออกมาในปี ค.ศ. 2010@fail0verflow2010 โดยในการใช้งานนั้นมีการใช้ค่าคงที่ $k$ ซึ่งเพียงแค่บิตบางส่วนของค่า nonce ที่รั่วไหลออกมา ก็เพียงพอต่อการกู้คืนคีย์ด้วยเทคนิคที่อาศัยโครงสร้างแบบแลตทิซ (lattice-based key recovery)@hgsmart2001 ทั้งนี้ มาตรฐาน RFC 6979@rfc6979 ได้ขจัดปัญหาการต้องพึ่งพาตัวสร้างตัวเลขสุ่ม โดยใช้วิธีคำนวณค่า $k$ แบบกำหนดผลลัพธ์ตายตัวจากค่า $d$ และ $H(m)$ แทน]]
})

#pagebreak()
== EdDSA and Ed25519

EdDSA@bernstein2012@rfc8032 เป็นรูปแบบลายเซ็นดิจิทัลในสไตล์ Schnorr ซึ่งสร้างขึ้นบนเส้นโค้ง Edwards แบบบิดเบี้ยว โดยได้รับการออกแบบมาเพื่อขจัดข้อบกพร่องต่าง ๆ ที่พบใน ECDSA สำหรับ Ed25519 ซึ่งเป็นรูปแบบที่รู้จักกันมากที่สุดของ EdDSA นั้น มีกระบวนการทำงานดังนี้: เริ่มต้นด้วยการนำค่าตั้งต้นที่เป็นความลับ (secret seed) ขนาด 32 ไบต์ มาผ่านฟังก์ชั่นแฮช SHA-512 ผลลัพธ์ที่ได้จะถูกแบ่งออกเป็นสองส่วน ส่วนแรกใช้เป็นค่าสเกลาร์ลับ $a$ โดยที่กุญแจสาธารณะคือ $A = a B$ (เมื่อ $B$ คือจุดฐาน หรือ base point) ส่วนอีกครึ่งหนึ่งจะถูกใช้เป็นค่าคำนำหน้าลับสำหรับการลงลายเซ็นในข้อความ $M$ มีขั้นตอนดังนี้:
$ r = H("prefix" || M), quad R = r B, quad S = (r + H(R || A || M) dot a) mod ell, $
#cont[โดยที่ $ell$ คืออันดับของกลุ่มที่เป็นจำนวนเฉพาะ ลายเซ็นคือ $(R, S)$ ผู้ตรวจสอบจะทำการตรวจสอบว่า $8 S B = 8 R + 8 H(R || A || M) A$]

เมื่อเปรียบเทียบกับ ECDSA แล้ว EdDSA มีข้อได้เปรียบในทางปฏิบัติหลายประการ:

- nonce เป็นแบบกำหนดได้ ดังนั้นเครื่องกำเนิดเลขสุ่มที่อ่อนแอจึงไม่สามารถรั่วไหลคีย์ได้
- การลงนามไม่จำเป็นต้องใช้การผกผันโมดูลาร์
- กฎการบวกของ Edwards ที่สมบูรณ์ไม่มีกรณีพิเศษ ซึ่งทำให้โค้ดเวลาคงที่ตรงไปตรงมา
- การตรวจสอบลายเซ็นจำนวนมากสามารถรวมกลุ่มกันเพื่อเพิ่มความเร็ว

Bitcoin ได้นำลายเซ็น BIP 340 Schnorr ที่เกี่ยวข้องอย่างใกล้ชิดมาใช้แทน secp256k1 ในการอัปเกรด Taproot ในปี 2021@bip340

== Elliptic Curve Integrated Encryption Scheme (ECIES)

โดยทั่วไปแล้ว ECC ไม่ค่อยถูกนำมาใช้ในการเข้ารหัสข้อมูลโดยตรง แต่จะใช้วิธีการเข้ารหัสแบบผสม เช่น ECIES ซึ่งเป็นการรวมกระบวนการแลกเปลี่ยนกุญแจแบบ ECDH ชั่วคราวเข้ากับการเข้ารหัสแบบสมมาตร โดยผู้ส่งจะสร้างคู่กุญแจชั่วคราวขึ้นมา $(e, E = e G)$ และคำนวณค่า $S = e Q_"recipient"$ จากนั้นนำค่า $S$ ไปผ่านฟังก์ชันสร้างกุญแจเพื่อให้ได้กุญแจสำหรับการเข้ารหัสและกุญแจสำหรับ MAC แล้วจึงส่งค่า $E$ ไปพร้อมกับข้อมูลที่เข้ารหัสซึ่งมีการตรวจสอบความถูกต้อง ทางด้านผู้รับจะคำนวณค่า $S$ ใหม่ด้วยสูตร $S = d E$ รูปแบบเดียวกันนี้ยังเป็นพื้นฐานของ HPKE (ตามมาตรฐาน RFC 9180) ซึ่งถูกนำไปใช้ใน TLS Encrypted Client Hello และ Messaging Layer Security อีกด้วย


#pagebreak()
// ── 4 Standard curves ────────────────────────────────────────

= Standardized Curves <sec:curves>

#line(length: 100%, stroke: 0.5pt + gray)

การจะสร้างพารามิเตอร์ของเส้นโค้งให้มีความปลอดภัยนั้น มีรายละเอียดที่ซับซ้อนและละเอียดมาก ดังนั้นในความเป็นจริงระบบส่วนใหญ่จึงเลือก "เส้นโค้งมาตรฐาน" ที่ผ่านการตรวจสอบมาอย่างดีแล้วเพียงไม่กี่แบบมาใช้งาน ตารางด้านล่างนี้สรุปเส้นโค้งที่นำไปใช้แพร่หลายจนถึงปัจจุบัน

#figure(
  {
    // Tighter lines than body text so rows stay compact; header in Regular.
    set par(justify: false, first-line-indent: 0pt, leading: 0.55em)
    set strong(delta: 0)
    show table.cell.where(y: 0): set text(weight: "regular")
    table(
      columns: (1.25fr, 1.15fr, 0.5fr, 0.85fr, 2fr),
      align: (left + horizon, left + horizon, center + horizon, center + horizon, left + horizon),
      stroke: 0.5pt + black,
      inset: (x: 6pt, y: 7pt),
      table.header(
        [ชื่อเส้นโค้ง], [รูปแบบสมการ ], [Bit], [ระดับความปลอดภัย], [ตัวอย่างการนำไปใช้งาน],
      ),
      [P-256 (secp256r1)], [Weierstrass], [256], [128], [TLS, FIDO2/WebAuthn, สมาร์ตการ์ด, บัตรประชาชน],
      [P-384], [Weierstrass], [384], [192], [ระบบของหน่วยงานรัฐบาล (มาตรฐาน CNSA 1.0)],
      [secp256k1], [Koblitz], [256], [128], [ระบบคริปโทเคอร์เรนซี เช่น Bitcoin, Ethereum],
      [brainpoolP256r1], [Weierstrass], [256], [128], [บัตร eID ของยุโรป และหน่วยงานรัฐ],
      [Curve25519], [Montgomery], [255], [\~128], [โปรโตคอล TLS 1.3, SSH, แอป Signal, WireGuard],
      [Ed25519], [Twisted Edwards], [255], [\~128], [คีย์ SSH, การเซ็นรับรองซอฟต์แวร์, เครือข่าย Tor],
      [Curve448 / Ed448], [Montgomery], [448], [\~224], [ระบบ TLS และลายเซ็นดิจิทัลที่ต้องการความปลอดภัยสูงมาก],
    )
  },
  caption: [เส้นโค้งมาตรฐานที่นำไปใช้งานอย่างแพร่หลาย],
) <tab:curves>

== รูปแบบของเส้นโค้ง

กลุ่มเดียวกันสามารถเขียนแทนได้ด้วยสมการที่แตกต่างกัน ซึ่งการเลือกใช้สมการนั้นส่งผลต่อทั้งความเร็วและความปลอดภัย

- #text(weight: "regular")[Short Weierstrass] แบบสั้น $y^2 = x^3 + a x + b$ เป็นรูปแบบทั่วไป ใช้เส้นโค้งของ NIST, SEC และ Brainpool สูตรการบวกมีกรณียกเว้น
- #text(weight: "regular")[Montgomery] คำนวณที่ทำงานได้รวดเร็ว $B y^2 = x^3 + A x^2 + x$ ใช้เวลาได้คงที่ โดนสมบัตินี้ทำให้ต้านด้วยการถูกแฮกด้วยกับจับเวลา เช่น X25519, X448

- #text(weight: "regular")[Twisted Edwards] $a x^2 + y^2 = 1 + d x^2 y^2$ กฎการบวกสมบูรณ์ที่ไม่มีกรณียกเว้น และเป็นรูปแบบที่เร็วที่สุด (Ed25519, Ed448)

เพื่อหลีกเลี่ยงการผกผันในฟิลด์ที่มีต้นทุนสูง การใช้งานจึงใช้พิกัดเชิงโปรเจกทีฟหรือพิกัดจาโคเบียนด้วยตัวอย่างเช่น สามพิกัดจาโคเบียน $(X : Y : Z)$ แสดงถึงจุดแอฟฟีน $(X \/ Z^2, Y \/ Z^3)$ ดังนั้นการคูณสเกลาร์จึงต้องการการผกผันเพียงครั้งเดียวในตอนท้าย

== ความเชื่อมั่นในการสร้างเส้นโค้ง

เส้นโค้งของ NIST ถูกเผยแพร่ในปี ค.ศ. 1999 โดยมีที่มาจากค่าเริ่มต้น ซึ่งไม่เคยมีการอธิบายถึงแหล่งกำเนิดที่แน่ชัด หลังจากมีการเปิดเผยข้อมูลในปี ค.ศ. 2013 เกี่ยวกับอัลกอรีทึมสร้างตัวเลขสุ่ม Dual\_EC\_DRBG ที่มีการฝังช่องโหว่ไว้ ผู้คนจำนวนมากในวงการนี้จึงออกมาตั้งคำถามว่า ค่าคงที่ที่ไม่มีการอธิบายที่มาเหล่านี้อาจแฝงจุดอ่อนเอาไว้หรือไม่ แม้ว่าจะยังไม่มีการค้นพบการโจมตีใดๆ ต่อเส้นโค้ง P-256 และเส้นโค้งดังกล่าวยังคงได้รับการรับรองและยังใช้งานอย่างแพร่หลาย แต่เหตุการณ์ดังกล่าวก็เกิดการตั้งคำถาม และการต้องการความโปร่งใส ที่สามารถตรวจสอบได้ชัดเจนมากยิ่งขึ้น เช่น Curve25519 และ Brainpool@rfc5639 ซึ่งพารามิเตอร์ต่างๆ ถูกกำหนดขึ้นตามกฎเกณฑ์ที่โปร่งใส ทั้งนี้ในปี ค.ศ. 2023 NIST ได้เพิ่ม Curve25519 และ Curve448 เข้าไว้ในข้อแนะนำใน SP 800-186@sp800-186 และ FIPS 186-5@fips186-5

// ── 5 Implementation ─────────────────────────────────────────

= Implementation Security <sec:impl>

#line(length: 100%, stroke: 0.5pt + gray)

ทฤษฎีคณิตศาสตร์พื้นฐานของ ECC มีระบบรักษาความปลอดภัยที่แข็งแรงมาตลอด การที่ระบบคริปโตถูกแฮกแทบจะเกิดจากความผิดพลาดในขั้นตอน "การนำไปเขียนโค้ดหรือสร้างระบบจริง" ทั้งสิ้น โดยข้อผิดพลาดที่เจอบ่อยมีดังนี้

- #text(weight: "regular")[โดนจับผิดพฤติกรรมการทำงาน]

#cont[หากโค้ดที่เราเขียนมามีการใช้คำสั่ง หรือใช้เวลาคำนวณช้า-เร็วไม่เท่ากัน แฮกเกอร์สามารถเดา "Private key" ได้จากการจับเวลาที่คอมพิวเตอร์ใช้ประมวลผล แอบวัดอัตราการกินไฟ หรือดูดคลื่นแม่เหล็กไฟฟ้าที่แผ่ออกมา]

#text(weight: "regular")[วิธีแก้:] ต้องเขียนโค้ดแบบใช้เวลาทำงานเท่ากันเสมอ รวมถึงใช้เทคนิคทางคณิตศาสตร์ เช่น Montgomery ladder และการสุ่มเพื่อพรางข้อมูลไม่ให้เดาได้
#pagebreak()
- #text(weight: "regular")[โดนหลอกด้วยข้อมูลนอกเส้นโค้ง]

#cont[ถ้าเราเขียนโปรแกรมรับข้อมูลเข้ามา โดยไม่ตรวจเช็กให้ดีว่า "จุด" ที่รับเข้ามาอยู่บนเส้นโค้งจริง ๆ หรือไม่ แฮกเกอร์อาจจะจงใจส่งข้อมูลของเส้นโค้งอื่นที่อ่อนแอกว่ามาให้ระบบคำนวณ ซึ่งทำให้แฮกเกอร์แงะ Private key ได้ทีละส่วน (ระบบ TLS เคยโดนเจาะด้วยวิธีนี้มาแล้ว@jager2015)]

#text(weight: "regular")[วิธีแก้:] ต้องตรวจสอบทุกข้อมูลที่รับเข้ามาเสมอ หรือเปลี่ยนไปใช้เส้นโค้งที่มีการออกแบบมาเพื่อป้องกันเรื่องนี้แต่แรก อย่างเช่น Curve25519

- #text(weight: "regular")[ระบบสุ่มเลขมีปัญหาตอนเซ็นชื่อ]

#cont[ในการสร้างลายเซ็นดิจิทัล ระบบจะต้องใช้ตัวเลขสุ่มที่เรียกว่า Nonce หากระบบสุ่มเลขออกมาซ้ำกัน เดาทางได้ หรือสุ่มไม่ดี Private key ของเราจะถูกเปิดเผยให้แฮกเกอร์รู้]

#text(weight: "regular")[วิธีแก้:] เลิกพึ่งพาระบบสุ่มเลขในจังหวะที่ทำการเซ็น แต่เปลี่ยนไปใช้วิธีสร้าง Nonce แบบคำนวณตายตัวตามมาตรฐาน เช่น RFC 6979@rfc6979 หรือ EdDSA@rfc8032 แทน

- #text(weight: "regular")[ความสับสนเรื่องรูปแบบข้อมูล]

#cont[เส้นโค้งบางแบบยอมให้ข้อมูลลายเซ็นหรือจุด "ตัวเดียวกัน" สามารถเขียนออกมาในรูปแบบที่หน้าตาต่างกันได้ เช่น คำว่า "รถยนต์" กับ "รถ" ที่ความหมายเดียวกันแต่เขียนต่างกัน สิ่งนี้ทำให้ระบบที่คิดเอาเองว่ารูปแบบข้อมูลต้องมีแค่อย่างเดียว ทำงานรวนหรือเกิดบั๊กได้]

#text(weight: "regular")[วิธีแก้:] ใช้เครื่องมือช่วย เพื่อบังคับให้ข้อมูลอ่านได้รูปแบบเดียวอย่างชัดเจน เช่น Ristretto255

- #text(weight: "regular")[แกล้งทำให้ฮาร์ดแวร์ทำงานรวน]

#cont[แฮกเกอร์อาจโจมตีทางฮาร์ดแวร์ เช่น แกล้งกระตุกกระแสไฟขณะที่อุปกรณ์กำลังคำนวณรหัสผ่าน เพื่อทำให้ฮาร์ดแวร์ทำงานเพี้ยนจนรหัสหลุดออก]

#text(weight: "regular")[วิธีแก้:] อุปกรณ์อย่างสมาร์ตการ์ดจะต้องออกแบบให้ตรวจสอบผลลัพธ์การคำนวณของตัวเองก่อนส่งข้อมูลออกไป

#par(first-line-indent: 0pt)[การเขียนโค้ดระบบ ECC ให้ปลอดภัยนั้นมีรายละเอียดจุกจิกที่ต้องระวังเยอะมาก ข้อแนะนำคือ "อย่าเขียนโค้ดเข้ารหัสขึ้นมาใช้งานเอง" แต่ควรไปหยิบเอาไลบรารีที่สร้างไว้แล้วและถูกตรวจสอบแล้วมาใช้งานแทนจะปลอดภัยกว่ามาก]

#pagebreak()
// ── 6 Quantum ────────────────────────────────────────────────

= The Quantum Threat and Post-Quantum Migration <sec:quantum>

#line(length: 100%, stroke: 0.5pt + gray)

อัลกอริทึมของ Shor@shor1997 แก้ปัญหาทั้งการแยกตัวประกอบและลอการิทึมไม่ต่อเนื่องในกลุ่มอาบีเลียนจำกัดใด ๆ ได้ในเวลาพหุนามบนควอนตัมคอมพิวเตอร์ที่ทนต่อข้อผิดพลาดที่มีขนาดใหญ่พอสมควร ซึ่งรวมถึง ECDLP ด้วย ดังนั้นควอนตัมคอมพิวเตอร์ที่เกี่ยวข้องกับการเข้ารหัส หรือ CRQC จึงจะทำลาย ECDH, ECDSA และ EdDSA ได้อย่างสมบูรณ์ไม่ว่าขนาดคีย์จะเป็นเท่าใด

เนื่องจากคีย์ ECC มีขนาดเล็ก จึงอาจถูกควอนตัมคอมพิวเตอร์ถอดรหัสได้ก่อน RSA ในระดับความปลอดภัยแบบดั้งเดิมที่เทียบเคียงได้ Roetteler et al.@roetteler2017 ประมาณการว่าการคำนวณลอการิทึมไม่ต่อเนื่องบน P-256 ต้องการคิวบิตเชิงตรรกะประมาณ $9n + 2 ceil(log_2 n) + 10 approx 2330$ คิวบิต ซึ่งน้อยกว่าที่ประมาณสำหรับแยกตัวประกอบ RSA-3072 แม้ว่าวงจรจะยังคงลึกมากก็ตาม อุปกรณ์ในปัจจุบันยังห่างจากระดับนี้หลายเท่าตัว แต่ความเสี่ยงของการเก็บข้อมูลตอนนี้แล้วถอดรหัสภายหลังนั้นก็เป็นเรื่องจริง การรับส่งข้อมูลที่เข้ารหัสซึ่งบันทึกไว้ในปัจจุบันอาจจะถูกถอดรหัสได้เมื่อมี CRQC ดังนั้นการแลกเปลี่ยนคีย์จะต้องถูกย้ายไปก่อนที่จะมีการสร้าง CRQC ขึ้นมา

NIST ได้เผยแพร่มาตรฐานการเข้ารหัสลับหลังยุคควอนตัมฉบับแรกในเดือนสิงหาคม ค.ศ. 2024 ได้แก่ ML-KEM ตามมาตรฐาน FIPS 203 สำหรับการห่อหุ้มคีย์@fips203 และ ML-DSA ตามมาตรฐาน FIPS 204 กับ SLH-DSA สำหรับลายเซ็นดิจิทัล@fips204 ส่วนแผนการเปลี่ยนผ่านฉบับร่างของ NIST เสนอให้เลิกใช้อัลกอริทึมที่เสี่ยงต่อควอนตัม เช่น ECDH และ ECDSA หลังปี ค.ศ. 2030 และไม่อนุญาตให้ใช้หลังปี ค.ศ. 2035@nistir8547

กลยุทธ์การโยกย้ายที่แพร่หลายคือการเข้ารหัสลับแบบไฮบริด โดยให้อัลกอริทึมแบบดั้งเดิมและแบบหลังยุคควอนตัมทำงานร่วมกัน และเซสชันจะปลอดภัยตราบใดที่อัลกอริทึมตัวใดตัวหนึ่งยังไม่ถูกทำลาย การแลกเปลี่ยนคีย์แบบไฮบริด X25519MLKEM768 ถูกเปิดใช้งานโดยค่าเริ่มต้นในเบราว์เซอร์หลักและ CDN อยู่แล้ว ดังนั้น ECC ยังคงเป็นส่วนสำคัญของระบบที่ใช้งานอยู่ระหว่างช่วงเปลี่ยนผ่าน โดยปัจจุบันทำงานร่วมกับแผนการที่ใช้แลตทิซ แทนที่จะถูกแทนที่ในชั่วข้ามคืน

#pagebreak()
// ── 7 Conclusion ─────────────────────────────────────────────

= Conclusion <sec:conclusion>

#line(length: 100%, stroke: 0.5pt + gray)

Elliptic Curve Cryptography (ECC) วิทยาการเข้ารหัสด้วยเส้นโค้งวงรี เปลี่ยนกฎเรขาคณิตอย่างง่าย โดยการบวกจุดบนเส้นเชื่อมและเส้นสัมผัสของจุดต่าง ๆ ให้เป็นกลุ่มก้อนที่ปัญหาลอการิทึมแบบไม่ต่อเนื่อง สามารถต้านทานการโจมตีแบบดั้งเดิมได้ทั้งหมด ยกเว้นอัลกอริทึมรากที่สองทั่วไป ทำให้เป็นข้อได้เปรียบที่สำคัญของ ECC คือเรื่องของความปลอดภัย ประมาณ 128 บิตจากคีย์ 256 บิตที่กระทัดรัดและรวดเร็ว คุณสมบัติเหล่านี้ทำให้ ECC กลายเป็นเทคโนโลยีคีย์สาธารณะพื้นฐานที่สำคัญ สำหรับอินเทอร์เน็ต, อุปกรณ์เคลื่อนที่และฝังตัว รวมถึงสกุลเงินดิจิทัล

จากประวัติศาสตร์ของ ECC ยังช่วยบอกได้ว่า คณิตศาสตร์ที่แข็งแกร่งนั้นยังคงจำเป็นแต่ก็ไม่เพียงพอ เส้นโค้งที่อ่อนแอ, อินพุตที่ไม่ได้รับการตรวจสอบ, ช่องทางข้างและการใช้โนนซ์ผิดวิธี ทำให้เกิดช่องโหว่มากกว่าความก้าวหน้าใด ๆ ในการต่อต้าน ECDLP การออกแบบสมัยใหม่ เช่น Curve25519 และ Ed25519 ตอบสนองด้วยการทำให้การสร้างระบบที่ปลอดภัยให้ง่ายที่สุด อนาคตการคำนวณควอนตัมยังทำให้ ECC อาจเริ่มมีอายุการใช้งานที่จำกัดลง อย่างไรก็ตามอย่างน้อยในอีกทศวรรษข้างหน้า ECC ก็จะยังคงมีการใช้งานได้ต่อไป โดยจะมีบทบาทมากขึ้นในฐานะครึ่งหนึ่งของโครงสร้างแบบไฮบริดที่ผสมการเข้ารหัสลับดั้งเดิมกับแบบหลังยุคควอนตัม

#pagebreak(weak: true)
#bibliography("refs.bib", title: [References], style: "ieee")
