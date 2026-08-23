.pragma library

function normalize(value) {
  return String(value || "").toLowerCase().trim().replace(/\s+/g, " ")
}

function words(value) {
  return normalize(value).split(/[\s\-_]+/).filter(function (word) {
    return word.length > 0
  })
}

function distance(left, right) {
  var previous = []
  var current = []
  var i
  var j

  for (j = 0; j <= right.length; j++) previous[j] = j

  for (i = 1; i <= left.length; i++) {
    current[0] = i
    for (j = 1; j <= right.length; j++) {
      var cost = left[i - 1] === right[j - 1] ? 0 : 1
      current[j] = Math.min(
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + cost
      )
    }
    var swap = previous
    previous = current
    current = swap
  }

  return previous[right.length]
}

function fuzzyScore(text, query) {
  if (query.length < 3) return 0

  var maxDistance = query.length <= 4 ? 1 : 2
  var best = 0
  var candidates = words(text)
  candidates.push(normalize(text))

  for (var i = 0; i < candidates.length; i++) {
    var candidate = candidates[i]
    if (Math.abs(candidate.length - query.length) > maxDistance) continue
    var currentDistance = distance(candidate, query)
    if (currentDistance <= maxDistance) {
      var length = Math.max(candidate.length, query.length)
      best = Math.max(best, 1 - currentDistance / length)
    }
  }

  return best
}

function fieldScore(value, query) {
  var text = normalize(value)
  if (!text) return 0
  if (text === query) return 10000
  if (text.indexOf(query) === 0) return 8000

  var textWords = words(text)
  for (var i = 0; i < textWords.length; i++) {
    if (textWords[i].indexOf(query) === 0) return 6500
  }

  if (text.indexOf(query) !== -1) return 4000
  var fuzzy = fuzzyScore(text, query)
  return fuzzy > 0 ? 1500 + fuzzy * 500 : 0
}

function keywordScore(keywords, query) {
  var best = 0
  for (var i = 0; i < (keywords || []).length; i++) {
    best = Math.max(best, fieldScore(keywords[i], query))
  }
  return best
}

function score(record, query) {
  var q = normalize(query)
  if (!q) return 0

  var name = fieldScore(record.name, q)
  var generic = fieldScore(record.genericName, q) * 0.65
  var keyword = keywordScore(record.keywords, q) * 0.5
  var comment = fieldScore(record.comment, q) * 0.35
  var category = keywordScore(record.categories, q) * 0.25

  return Math.max(name, generic, keyword, comment, category)
}

function compareByName(left, right) {
  var leftName = normalize(left.name)
  var rightName = normalize(right.name)
  var nameResult = leftName < rightName ? -1 : leftName > rightName ? 1 : 0
  if (nameResult !== 0) return nameResult
  var leftId = String(left.id)
  var rightId = String(right.id)
  return leftId < rightId ? -1 : leftId > rightId ? 1 : 0
}

function rank(records, query, category) {
  var q = normalize(query)
  var filtered = []

  for (var i = 0; i < (records || []).length; i++) {
    var record = records[i]
    if (category && category !== "All Programs" && record.category !== category) continue

    var currentScore = q ? score(record, q) : 0
    if (q && currentScore <= 0) continue

    filtered.push({ record: record, score: currentScore })
  }

  filtered.sort(function (left, right) {
    if (right.score !== left.score) return right.score - left.score
    return compareByName(left.record, right.record)
  })

  return filtered.map(function (item) {
    return item.record
  })
}
