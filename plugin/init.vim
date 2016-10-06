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


nnoremap <leader>ftu :call ToggleFeeluownUser()<cr>
nnoremap <leader>fpn :FeeluownPlayNext<cr>
nnoremap <leader>fpp :FeeluownPlayPrevious<cr>
nnoremap <leader>fpt :FeeluownPlayOrPause<cr>
