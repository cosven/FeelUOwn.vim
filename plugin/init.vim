" --------------------------------------
" code in this block are copied from  http://majutsushi.github.com/tagbar/
"
" goto win
function! s:goto_win(winnr, ...) abort
    let cmd = type(a:winnr) == type(0) ? a:winnr . 'wincmd w'
                                     \ : 'wincmd ' . a:winnr
    let noauto = a:0 > 0 ? a:1 : 0

    if noauto
        noautocmd execute cmd
    else
        execute cmd
    endif
endfunction

" s:mark_window() {{{2
" Mark window with a window-local variable so we can jump back to it even if
" the window numbers have changed.
function! s:mark_window() abort
    let w:userwin_mark = 1
endfunction

" s:goto_markedwin() {{{2
" Go to a previously marked window and delete the mark.
function! s:goto_markedwin(...) abort
    let noauto = a:0 > 0 ? a:1 : 0
    for window in range(1, winnr('$'))
        call s:goto_win(window, noauto)
        if exists('w:userwin_mark')
            unlet w:userwin_mark
            break
        endif
    endfor
endfunction

" code in this block are copied from  http://majutsushi.github.com/tagbar/
" --------------------------------------


filetype plugin on
au! BufRead,BufNewFile *.feeluown set filetype=feeluown

func! ToggleFeeluownUser(...)
    let fuwinnr = bufwinnr('user.feeluown')
    if fuwinnr != -1
        " user window exist
        if winnr() == fuwinnr
            bwipeout
            " Try to jump to the correct window after closing
        else
            call s:mark_window()
            call s:goto_win(fuwinnr)
            bwipeout
            call s:goto_markedwin()
        endif
    else
        exec 'keepalt botright vertical 33 split user.feeluown'
        exec 'buffer user.feeluown'
        nnoremap <buffer> <CR> :call LoadPlaylist()<CR>
        exec 'FeeluownFillUserWin'
        setlocal nonumber nomodifiable buftype=nofile
            \ bufhidden=wipe readonly nobuflisted noswapfile
            \ winfixwidth
    endif
endfunc


func! LoadPlaylist(...)
    let fuwinnr = bufwinnr('user.feeluown')
    if winnr() != fuwinnr
        echo 'I cant do this'
    else
        let linetxt = getline('.')
        let fswinnr = bufwinnr('songs.feeluown')
        if fswinnr != -1
            call s:goto_win(fswinnr)
            bwipeout
        endif
        vsplit songs.feeluown
        buffer songs.feeluown
        nnoremap <buffer> <CR> :FeeluownPlaySong<CR>
        exec 'FeeluownLoadPlaylist ' . linetxt
        exec 'Tab /|'
        setlocal nonumber nomodifiable buftype=nofile
            \ bufhidden=wipe readonly nobuflisted noswapfile
        only
    endif
endfunc

func! GetSep()
    return "\ue0b1"
endfunc

func! GetReverseSep()
    return "\ue0b3"
endfunc

func! GetPlayerState()
    return "Playing"
endfunc

func! GetPlayerPosition()
    return "03:45"
endfunc

func! GetPlayerMode()
    return "Random"
endfunc

func! CustomizeStatusLinea(title, artist_name, player_position, player_state, player_mode)
    set statusline=%#Search#\ %{GetPlayerState()}\ 
    set statusline+=%#MatchParen#\ %{GetPlayerMode()}\ 
    set statusline+=%#TablineFill#\ %{GetPlayerPosition()}\ 
    set statusline+=%#StatusLine#
    set statusline+=%=
    " set statusline+=%#Structure#%{GetReverseSep()}
    set statusline+=%#StatusLine#
    set statusline+=%#String#\ a:title
    set statusline+=%#Tag#\ -\ 
    set statusline+=%#Boolean#a:artist_name 
endfunc

let w:airline_disabled=1
call CustomizeStatusLinea('Sugar', 'Maroon5', '4:40', 'Playing', 'Random')


nnoremap <leader>ftu :call ToggleFeeluownUser()<cr>
nnoremap <leader>fpn :FeeluownPlayNext<cr>
nnoremap <leader>fpp :FeeluownPlayPrevious<cr>
nnoremap <leader>fpt :FeeluownPlayOrPause<cr>
