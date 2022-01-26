import std/[strutils, strformat, re]

type
  ParserError* = object of CatchableError
  ParserKind = enum
    pkString,
    pkRegexp

  Parser = ref object
    case kind: ParserKind
    of pkString:
      target: string
    of pkRegexp:
      regexp: Regex
      definition: string

proc parseString(target: string): Parser =
  Parser(kind: pkString, target: target)

proc parseRegexp(target: string): Parser =
  Parser(kind: pkRegexp, regexp: target.re, definition: target)

proc map[T](target: string, op: proc (s: string): T): T =
  op(target)

proc parse(p: Parser, input: string): string =
  case p.kind
    of pkString:
      if input.startsWith(p.target):
        return p.target
      raise newException(ParserError, fmt"Parser failure: <{p.target}> not found")
    of pkRegexp:
      let res = input.findAll(p.regexp)
      if input.startsWith(p.regexp):
        return res[0]
      raise newException(ParserError, fmt"Parser failure: <{p.definition}> not found")


when isMainModule:
  let fooParser = parseString("foo")
  let barParser = parseString("bar")
  echo fooParser.parse("foobar")
  echo barParser.parse("bar !!")
  let intParser = parseRegexp("[0-9]+")
  echo intParser.parse("123").map(parseInt)
