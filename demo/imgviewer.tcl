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

	variable mag 1.0

	component disp

	constructor {simg} {
		set sourceimg $simg

		set zoomimg [image create photo]
		set height [image height $simg]
		set width [image width $simg]
		
		install disp using label $win.l -image $zoomimg -width 300 -height 200
		pack $disp -expand yes -fill both
		bind $disp <Configure> [mymethod fit_window]
	}

	method redraw {} {
		set x0 0
		set y0 0
		set x1 [expr {$width - 1}] 
		set y1 [expr {$height - 1}]

		set dispwidth [winfo width $win]
		set dispheight [winfo height $win]

		resizephoto $sourceimg $zoomimg $x0 $y0 $x1 $y1 $dispwidth $dispheight
	}

	method fit_window {} {
		set winwidth [winfo width $win]
		set winheight [winfo height $win]

		set magx [expr {double($winwidth) / $width}]
		set magy [expr {double($winheight) / $height}]

		set mag [expr {min($magx, $magy)}]
		
		puts "Mag: $mag"
		
		set x0 0
		set y0 0

		$self fit_aspect
	}

	method fit_aspect {} {
		# Input: x0, y0, mag
		# Compute source region such that the window is filled
		# with the left upper corner at x0,y0

		set winwidth [winfo width $win]
		set winheight [winfo height $win]

		set cropwidth [expr {entier(ceil(max(1.0, $winwidth / $mag)))}]
		set cropheight [expr {entier(ceil(max(1.0, $winheight / $mag)))}]

		set x1 [expr {$x0 + $cropwidth - 1}]
		set y1 [expr {$y0 + $cropwidth - 1}]

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
		
		puts "resizephoto $sourceimg $zoomimg $x0 $y0 $x1 $y1 $dispwidth $dispheight"
		resizephoto $sourceimg $zoomimg $x0 $y0 $x1 $y1 $dispwidth $dispheight


	}

	method scroll_zoom {x0_ y0_ mag_} {
		set x0 $x0_
		set y0 $y0_
		set mag $mag_
		
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

	destructor {
		if {[catch {image delete $zoomimg} err]} {
			puts "Error in destructor: $err"
		}
	}
}

set harbour [image create photo -file harbour.jpg]
imgviewer .img $harbour

pack .img -expand yes -fill both




