lappend auto_path ..
package require Img
package require photoresize 0.2
package require snit

snit::widget imgviewer {

	variable sourceimg 
	variable height
	variable width
	variable zoomimg

	variable x0 0
	variable y0 0
	variable x1 0
	variable y1 0
	variable xc 0
	variable yc 0

	variable winwidth
	variable winheight

	variable mag 1.0

	variable dragcoords {}

	component disp

	constructor {simg} {
		set sourceimg $simg

		set zoomimg [image create photo]
		set height [image height $simg]
		set width [image width $simg]
		
		install disp using label $win.l -image $zoomimg -width 300 -height 200 -takefocus true
		pack $disp -expand yes -fill both
		bind $disp <Configure> [mymethod fit_aspect]
		bind $disp <Key-plus> [mymethod zoomin]
		bind $disp <Key-minus> [mymethod zoomout]

		bind $disp <ButtonPress-1> [mymethod dragstart %x %y]
		bind $disp <B1-Motion> [mymethod dragmove %x %y]
		bind $disp <ButtonRelease-1> [mymethod dragend]

		focus $disp ;# how can this be avoided ?

		#$self fit_window
	}

	method fit_window {} {
		set winwidth [winfo width $win]
		set winheight [winfo height $win]

		set magx [expr {double($winwidth) / $width}]
		set magy [expr {double($winheight) / $height}]

		set mag [expr {min($magx, $magy)}]
		
		puts "Mag: $mag"
		
		set xc [expr {$width / 2.0}]
		set yc [expr {$height / 2.0}]

		$self fit_aspect
	}

	method fit_aspect {} {
		# Input: xc, yc, mag
		# Compute source region such that the window is filled
		# centered at xc,yc

		set winwidth [winfo width $win]
		set winheight [winfo height $win]

		set cropwidth [expr {max(1.0, $winwidth / $mag)}]
		set cropheight [expr {max(1.0, $winheight / $mag)}]

		set x0 [expr {max(0, entier(floor($xc - $cropwidth / 2.0)))}]
		set y0 [expr {max(0, entier(floor($yc - $cropheight / 2.0)))}]


		set x1 [expr {entier(ceil($x0 + $cropwidth - 1))}]
		set y1 [expr {entier(ceil($y0 + $cropheight - 1))}]

		if {$x1 >= $width} {
			set x1 [expr {$width - 1}]
			set dispwidth [expr {entier(ceil(($x1 - $x0 + 1) * $mag))}]
		} else {
			set dispwidth $winwidth
		}

		if {$y1 >= $height} {
			set y1 [expr {$height - 1}]
			set dispheight [expr {entier(ceil(($y1 - $y0 + 1) * $mag))}]
		} else {
			set dispheight $winheight
		}	
		
		# puts "resizephoto $sourceimg $zoomimg $x0 $y0 $x1 $y1 $dispwidth $dispheight"
		resizephoto $sourceimg $zoomimg $x0 $y0 $x1 $y1 $dispwidth $dispheight


	}

	method scrollto {xc_ yc_} {
		set xc $xc_
		set yc $yc_
		
		$self fit_aspect
	}

	method zoomin {} {
		set mag [expr {$mag*1.3}]
		$self fit_aspect
	}

	method zoomout {} {
		set mag [expr {$mag/1.3}]
		$self fit_aspect
	}

	method zoom_onetoone {} {
		set mag 1.0
		$self fit_aspect
	}

	method pixtocoord {x y} {
		# convert pixel coordinates into image coords
		set xm [expr {$x/$mag + $x0}]
		set ym [expr {$y/$mag  + $y0}]
		list $xm $ym
	}

	method dragstart {x y} {
		set dragcoords [list $x $y $xc $yc]
		puts "$x $y -> [$self pixtocoord $x $y]"
	}

	method dragmove {x y} {
		if {$dragcoords eq {}} { return }
		lassign $dragcoords xs ys xsc ysc

		set xc [expr {($xs - $x)/$mag + $xsc}]
		set yc [expr {($ys - $y)/$mag + $ysc}]

		puts "Move to $xc $yc"
		$self fit_aspect

	}

	method dragend {} {
		set dragcoords {}
	}

	destructor {
		if {[catch {image delete $zoomimg} err]} {
			puts "Error in destructor: $err"
		}
	}
}

set harbour [image create photo -file harbour.jpg]
imgviewer .img $harbour

pack .img -expand yes -fill both




