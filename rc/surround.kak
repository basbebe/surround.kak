hook global ModuleLoaded surround %{
  surround-init
}

provide-module surround %{

  # Surround
  declare-user-mode surround

  define-command -hidden surround-init %{
    # Insert mode
    map global surround -docstring 'Enter insert mode' i ': surround-enter-insert-mode<ret>'

    # Mirror prompt
    map global surround -docstring 'Prompt for a pair to mirror' m ': surround-mirror-prompt<ret>'

    # Tag prompt
    map global surround -docstring 'Prompt for a tag' t ': surround-tag-prompt<ret>'

    # Editing
    map global surround -docstring '␣' <space> ': surround-add-space<ret>'
    map global surround -docstring '␤' <ret> ': surround-add-line<ret>'
    map global surround -docstring '⌫' <backspace> ': surround-delete<ret>'
    map global surround -docstring '⌫' <del> ': surround-delete<ret>'

    # Surrounding pairs
    surround-map-docstring 'Parenthesis block' global b ( )
    surround-map-docstring 'Braces block' global B { }
    surround-map-docstring 'Brackets block' global r [ ]
    surround-map-docstring 'Angle block' global a <lt> <gt>
    surround-map-docstring 'Double quote string' global Q '"' '"'
    surround-map-docstring 'Single quote string' global q "'" "'"
    surround-map-docstring 'Grave quote string' global g ` `
    surround-map-docstring 'Double quotation mark' global <a-Q> “ ”
    surround-map-docstring 'Single quotation mark' global <a-q> ‘ ’
    surround-map-docstring 'Double angle quotation mark' global <a-G> « »
    surround-map-docstring 'Single angle quotation mark' global <a-g> ‹ ›

    # Support for _emphasis_ and **strong** tagging
    map global surround -docstring 'Emphasis' '_' ': surround-add _ _<ret>'
    map global surround -docstring 'Strong' '*' ': surround-add ** **<ret>'
  }

  # Create mappings

  define-command surround-map -params 4 -docstring 'surround-map <scope> [alias] <opening> <closing>: Create surround mappings.' %{
    surround-map-docstring "%arg{3}…%arg{4}" %arg{@}
  }

  define-command surround-map-docstring -params 5 -docstring 'surround-map-docstring <docstring> <scope> [alias] <opening> <closing>: Create surround mappings.' %{
    # Let’s just pretend surrounding pairs can’t be cats.
    try %{ map %arg{2} surround -docstring %arg{1} %arg{3} ": surround-add %%🐈%arg{4}🐈 %%🐈%arg{5}🐈<ret>" }
    try %{ map %arg{2} surround -docstring %arg{1} %arg{4} ": surround-add %%🐈%arg{4}🐈 %%🐈%arg{5}🐈<ret>" }
    try %{ map %arg{2} surround -docstring %arg{1} %arg{5} ": surround-add %%🐈%arg{4}🐈 %%🐈%arg{5}🐈<ret>" }
  }

  # Enter insert mode
  define-command surround-enter-insert-mode -docstring 'Enter insert mode' %{
    execute-keys -save-regs '' 'Z'
    hook -always -once window ModeChange 'pop:insert:normal' %{
      hook -always -once window ModeChange 'pop:insert:normal' %{
        execute-keys z
        set-register ^
        echo
      }
      execute-keys -with-hooks a
    }
    execute-keys -with-hooks i
  }

  # Mirror prompt
  define-command surround-mirror-prompt -docstring 'Prompt for a pair to mirror' %{
    prompt surround-mirror: %{
      surround-add %val{text} %val{text}
    }
  }

  # Tag prompt
  define-command surround-tag-prompt -docstring 'Prompt for a tag' %{
    prompt surround-tag: %{
      surround-add "<%val{text}>" "</%val{text}>"
    }
  }

  # Add a surrounding pair
  define-command -hidden surround-add -params 2 %{
    surround-insert-text %arg{1}
    surround-append-text %arg{2}
  }

  define-command -hidden surround-add-space %{
    surround-add ' ' ' '
  }

  define-command -hidden surround-add-line %{
    execute-keys -draft 'i<ret>'
    execute-keys -draft 'a<ret>'
    execute-keys -draft 'K<a-:>J<a-&>'
    execute-keys -draft '<gt>'
  }

  # Delete surrounding
  define-command -hidden surround-delete %{
    # Delete left surrounding
    try %{
      execute-keys -draft '<a-:><a-;>h<a-a><space>d'
    } catch %{
      execute-keys -draft 'i<backspace>'
    }
    # Delete right surrounding
    try %{
      execute-keys -draft '<a-:>l<a-a><space>d'
    } catch %{
      execute-keys -draft 'a<del>'
    }
  }

  # Generics ───────────────────────────────────────────────────────────────────

  define-command -hidden surround-insert-text -params 1 %{
    surround-paste-text 'P' %arg{1}
  }

  define-command -hidden surround-append-text -params 1 %{
    surround-paste-text 'p' %arg{1}
  }

  define-command -hidden surround-paste-text -params 2 %{
    evaluate-commands -save-regs '"' %{
      # Paste using the specified method
      # The command (R, <a-P> and <a-p>) selects inserted text
      set-register '"' %arg{2}
      execute-keys %arg{1}
    }
  }
}

require-module surround
