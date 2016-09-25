{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'find-trailing-whitespace:find': => @find()

  deactivate: ->
    @subscriptions.dispose()

  findNext: (cursor_pos, ranges) ->
    for range in ranges
      if (range.end > cursor_pos)
        return range

    ranges[0]

  find: ->
    if editor = atom.workspace.getActiveTextEditor()
      search_start_pos = [0, 0]
      search_end_pos = editor.getEofBufferPosition()
      regexSearch = "[ \t]+$"
      regexFlags = 'g'
      range =  [search_start_pos, search_end_pos]

      ranges = []
      editor.scanInBufferRange new RegExp(regexSearch, regexFlags), range,
        (result) ->
          ranges.push result.range

      if ranges.length < 1
        @showSuccess('No trailing whitespace found!')
        return

      cursor_pos = editor.getCursorBufferPosition()
      range = @findNext(cursor_pos, ranges)
      editor.setSelectedBufferRange(range)

  showSuccess: (message, options={ dismissable: true }) ->
    title='Find Trailing Whitespace'
    options.detail = message
    options.timeOut ?= 2000
    {timeOut} = options
    notification = atom.notifications.addSuccess title, options
    setTimeout((-> notification.dismiss()), timeOut)
    notification
