#let article(
  title: none,
  subtitle: none,
  author: none,
  date: none,
  doc,
) = {

  // ─── Title block ──────────────────────────────────────────────────────────

  if title != none [
    #block(below: 0.8em)[
      #set text(font: "Source Sans 3", size: 24pt, weight: "bold", fill: rgb("#e50076"))
      #title
    ]
  ]

  if subtitle != none [
    #block(below: 2em)[
      #set text(font: "Source Sans 3", size: 16pt, weight: "regular", fill: luma(50))
      #subtitle
    ]
  ]

  if author != none or date != none [
    #block(below: 3em)[
      #set text(font: "Source Sans 3", size: 11pt, weight: "regular", fill: luma(100))
      #if author != none [
        #author
        #v(-0.8em)
      ]
      #if date != none [
        #date
        #v(0.5em)
      ]
    ]
  ]

  // ─── Main body ──────────────────────────────────────────────────────────

  set text(
    font: "Source Sans 3",
    size: 11pt,
    fill: luma(20),
    hyphenate: false,
  )

  set par(
    justify: false,
    leading: 0.75em,
    spacing: 1.2em,
  )

  show heading.where(level: 1): it => block(
    above: 1.8em,
    below: 0.3em,
  )[
    #set text(size: 14pt, weight: "bold", fill: luma(50))
    #it.body
    #v(-0.8em)
    #line(length: 100%, stroke: 0.5pt + rgb("#B3B3B3"))
    #v(0.4em)
  ]

  show heading.where(level: 2): it => block(
    above: 1.4em,
    below: 0.4em,
  )[
    #set text(size: 14pt, weight: "bold", fill: rgb("#1a3a5c"))
    #it.body
  ]

  show heading.where(level: 3): it => block(
    above: 1.1em,
    below: 0.3em,
  )[
    #set text(size: 12pt, weight: "semibold", fill: luma(30))
    #it.body
  ]

  show figure: it => [
    #v(2em)
    #it
    #v(2em)
  ]

  show figure.caption: it => align(left)[
    #set text(size: 9pt, fill: luma(100))
    #it
  ]

  set table(
    stroke: (x, y) => if y == 0 { (bottom: 1pt + luma(40)) } else { none },
    fill: (x, y) => if y == 0 { luma(230) } else if calc.odd(y) { luma(248) } else { white },
    inset: (x: 8pt, y: 5pt),
  )

  set table.header(repeat: true)

  show raw.where(block: true): it => block(
    fill: luma(245),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
  )[
    #set text(size: 9pt)
    #it
  ]

  show link: it => [
    #set text(fill: luma(20))
    #underline(stroke: 0.5pt + rgb("#e50076"), offset: 2pt, it)
  ]

  show ref: it => [
    #set text(fill: luma(20))
    #underline(stroke: 0.5pt + rgb("#e50076"), offset: 2pt, it)
  ]

  doc
}