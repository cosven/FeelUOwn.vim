" feeluown.vim
" -------------
"
" songs buffer name: songs.feeluown
" playlists buffer name: playlists.feeluown
"
let s:songsBufferName = "songs.feeluown" 

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
    let w:tagbar_mark = 1
endfunction

" s:goto_markedwin() {{{2
" Go to a previously marked window and delete the mark.
function! s:goto_markedwin(...) abort
    let noauto = a:0 > 0 ? a:1 : 0
    for window in range(1, winnr('$'))
        call s:goto_win(window, noauto)
        if exists('w:tagbar_mark')
            unlet w:tagbar_mark
            break
        endif
    endfor
endfunction

" --------------------------------------


filetype plugin on
au! BufRead,BufNewFile *.feeluown set filetype=feeluown

func! SongsBufferExists()
    if bufwinnr(s:songsBufferName) > 0
        echo "feeluown: songs buffers already exists."
        return 1
    endif
    return 0
endfunc

func! CreateSongsBuffer(...)
    if SongsBufferExists() > 0
        bwipeout s:songsBufferName
    endif
endfunc

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
        FeeluownShowUser
    endif
endfunc


nnoremap <leader>ftu :call ToggleFeeluownUser()<cr>
