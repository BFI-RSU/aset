#show: doc => article(
  title: [$title$],
  subtitle: [$subtitle$],
  author: [$for(author)$$author$$sep$, $endfor$],
  date: [$date$],
  doc,
)