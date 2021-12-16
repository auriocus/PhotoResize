lappend auto_path ..
package require Img
package require photoresize 0.2
package require snit

snit::widget imgviewer {

	variable sourceimg 
	variable height
	variable width
	variable zoomimg

	component disp

	constructor {simg} {
		set sourceimg $simg

		set zoomimg [image create photo]
		set height [image height $simg]
		set width [image width $simg]
		
		install disp using label $win.l -image $zoomimg
		pack $disp -expand yes -fill both
		bind $disp <Configure> [mymethod redraw]
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

	destructor {
		if {[catch {image delete $zoomimg} err]} {
			puts "Error in destructor: $err"
		}
	}
}

set harbour [image create photo -file harbour.jpg]
imgviewer .img $harbour

pack .img -expand yes -fill both


