		if ( ms["button"] == 2 && c < ($.ncols-1) ) {
			# do the right wall
			$.wallright[r][c] = addit
			if ( $.wallright[r][c] == 0 ) {
				$.grid.drawwallright(r,c,CLEAR)
			} else {
				color($.wallcolor)
				$.grid.drawwallright(r,c,STORE)
			}
		} else if ( ms["button"] == 1 && r < ($.nrows-1) ) {
			# toggle the bottom wall
			$.wallbottom[r][c] = addit
			if ( $.wallbottom[r][c] == 0 ) {
				$.grid.drawwallbottom(r,c,CLEAR)
			} else {
				color($.wallcolor)
				$.grid.drawwallbottom(r,c,STORE)
			}
		}
