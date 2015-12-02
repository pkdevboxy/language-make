describe "Makefile grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-make")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.makefile")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.makefile"

  it "selects the Makefile grammar for files that start with a hashbang make -f command", ->
    expect(atom.grammars.selectGrammar('', '#!/usr/bin/make -f')).toBe grammar

  it "parses comments correctly", ->
    lines = grammar.tokenizeLines '#foo\n\t#bar\n#foo\\\nbar'

    expect(lines[0][0]).toEqual value: '#', scopes: ['source.makefile', 'comment.line.number-sign.makefile', 'punctuation.definition.comment.makefile']
    expect(lines[0][1]).toEqual value: 'foo', scopes: ['source.makefile', 'comment.line.number-sign.makefile']
    expect(lines[1][0]).toEqual value: '\t', scopes: ['source.makefile', 'punctuation.whitespace.comment.leading.makefile']
    expect(lines[1][1]).toEqual value: '#', scopes: ['source.makefile', 'comment.line.number-sign.makefile', 'punctuation.definition.comment.makefile']
    expect(lines[1][2]).toEqual value: 'bar', scopes: ['source.makefile', 'comment.line.number-sign.makefile']
    expect(lines[2][0]).toEqual value: '#', scopes: ['source.makefile', 'comment.line.number-sign.makefile', 'punctuation.definition.comment.makefile']
    expect(lines[2][1]).toEqual value: 'foo', scopes: ['source.makefile', 'comment.line.number-sign.makefile']
    expect(lines[2][2]).toEqual value: '\\', scopes: ['source.makefile', 'comment.line.number-sign.makefile', 'constant.character.escape.continuation.makefile']
    expect(lines[3][0]).toEqual value: 'bar', scopes: ['source.makefile', 'comment.line.number-sign.makefile']

  it "parses recipes", ->
    lines = grammar.tokenizeLines 'all: foo.bar\n\ttest\n\nclean: foo\n\trm -fr foo.bar'

    expect(lines[0][0]).toEqual value: 'all', scopes: ['source.makefile', 'meta.scope.target.makefile', 'entity.name.function.target.makefile']
    expect(lines[3][0]).toEqual value: 'clean', scopes: ['source.makefile', 'meta.scope.target.makefile', 'entity.name.function.target.makefile']

  testFunctionCall = (functionName) ->
    {tokens} = grammar.tokenizeLine 'foo: echo $(' + functionName + ' /foo/bar.txt)'

    expect(tokens[4]).toEqual value: functionName, scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.prerequisites.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'support.function.' + functionName + '.makefile']

  it "parses `subst` correctly", ->
    testFunctionCall('subst')

  it "parses `patsubst` correctly", ->
    testFunctionCall('patsubst')

  it "parses `strip` correctly", ->
    testFunctionCall('strip')

  it "parses `findstring` correctly", ->
    testFunctionCall('findstring')

  it "parses `filter` correctly", ->
    testFunctionCall('filter')

  it "parses `sort` correctly", ->
    testFunctionCall('sort')

  it "parses `word` correctly", ->
    testFunctionCall('word')

  it "parses `wordlist` correctly", ->
    testFunctionCall('wordlist')

  it "parses `firstword` correctly", ->
    testFunctionCall('firstword')

  it "parses `lastword` correctly", ->
    testFunctionCall('lastword')

  it "parses `dir` correctly", ->
    testFunctionCall('dir')

  it "parses `notdir` correctly", ->
    testFunctionCall('notdir')

  it "parses `suffix` correctly", ->
    testFunctionCall('suffix')

  it "parses `basename` correctly", ->
    testFunctionCall('basename')

  it "parses `addsuffix` correctly", ->
    testFunctionCall('addsuffix')

  it "parses `addprefix` correctly", ->
    testFunctionCall('addprefix')

  it "parses `join` correctly", ->
    testFunctionCall('join')

  it "parses `wildcard` correctly", ->
    testFunctionCall('wildcard')

  it "parses `realpath` correctly", ->
    testFunctionCall('realpath')

  it "parses `abspath` correctly", ->
    testFunctionCall('abspath')

  it "parses `if` correctly", ->
    testFunctionCall('if')

  it "parses `or` correctly", ->
    testFunctionCall('or')

  it "parses `and` correctly", ->
    testFunctionCall('and')

  it "parses `foreach` correctly", ->
    testFunctionCall('foreach')

  it "parses `file` correctly", ->
    testFunctionCall('file')

  it "parses `call` correctly", ->
    testFunctionCall('call')

  it "parses `value` correctly", ->
    testFunctionCall('value')

  it "parses `eval` correctly", ->
    testFunctionCall('eval')

  it "parses `error` correctly", ->
    testFunctionCall('error')

  it "parses `warning` correctly", ->
    testFunctionCall('warning')

  it "parses `info` correctly", ->
    testFunctionCall('info')

  it "parses `shell` correctly", ->
    testFunctionCall('shell')

  it "parses `guile` correctly", ->
    testFunctionCall('guile')

  it "parses targets with line breaks in body", ->
    lines = grammar.tokenizeLines 'foo:\n\techo $(basename /foo/bar.txt)'

    expect(lines[1][3]).toEqual value: 'basename', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'support.function.basename.makefile']

  it "parses nested interpolated strings and function calls correctly", ->
    waitsForPromise ->
      atom.packages.activatePackage("language-shellscript")

    runs ->
      lines = grammar.tokenizeLines 'default:\n\t$(eval MESSAGE=$(shell node -pe "decodeURIComponent(process.argv.pop())" "${MSG}"))'

      expect(lines[1][1]).toEqual value: '$(', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']
      expect(lines[1][2]).toEqual value: 'eval', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'support.function.eval.makefile']
      expect(lines[1][5]).toEqual value: '$(', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']
      expect(lines[1][6]).toEqual value: 'shell', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'support.function.shell.makefile']
      expect(lines[1][9]).toEqual value: '"', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.quoted.double.shell', 'punctuation.definition.string.begin.shell']
      expect(lines[1][10]).toEqual value: 'decodeURIComponent(process.argv.pop())', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.quoted.double.shell']
      expect(lines[1][11]).toEqual value: '"', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.quoted.double.shell', 'punctuation.definition.string.end.shell']
      expect(lines[1][14]).toEqual value: '${', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.quoted.double.shell', 'variable.other.bracket.shell', 'punctuation.definition.variable.shell']
      expect(lines[1][16]).toEqual value: '}', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.quoted.double.shell', 'variable.other.bracket.shell', 'punctuation.definition.variable.shell']
      expect(lines[1][18]).toEqual value: ')', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']
      expect(lines[1][19]).toEqual value: ')', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']

  it "parses `origin` correctly", ->
    waitsForPromise ->
      atom.packages.activatePackage("language-shellscript")

    runs ->
      lines = grammar.tokenizeLines 'default:\n\t$(origin 1)'

      expect(lines[1][1]).toEqual value: '$(', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']
      expect(lines[1][2]).toEqual value: 'origin', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'support.function.origin.makefile']
      expect(lines[1][4]).toEqual value: '1', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'variable.other.makefile']
      expect(lines[1][5]).toEqual value: ')', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']

  it "parses `flavor` correctly", ->
    waitsForPromise ->
      atom.packages.activatePackage("language-shellscript")

    runs ->
      lines = grammar.tokenizeLines 'default:\n\t$(flavor 1)'

      expect(lines[1][1]).toEqual value: '$(', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']
      expect(lines[1][2]).toEqual value: 'flavor', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'support.function.flavor.makefile']
      expect(lines[1][4]).toEqual value: '1', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'variable.other.makefile']
      expect(lines[1][5]).toEqual value: ')', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']
