; by Pascal Saint-Hilaire 		shilaire@astro.phys.ethz.ch OR psainth@hotmail.com
;finished	2001/05/19
;
;PURPOSE:
;	Given an image, and an info structure containing at least the
;	following tags, maps the image using DMZ's mapping software,
;	with the hessi color table.
;
;INPUTS:
;	image : a 2-D array
;
;	infostruct : a structure which MUST have at least the folowing 
;				information tags on the image:
;						- xyoffset
;						- pixel_size
;						- absolute_time_range
;						- det_index_mask
;						- a2d_index_mask
;						- front_segment
;						- rear_segment
;						- energy_band
;						- binned_n_event
;						- image_algorithm
;
;	_extra : any keywords to be passed to hsi_plot_image AND/OR plot_map

;EXAMPLE:
;	to display a Jmm Qlook Image:
;		IDL>bla=mrdfits(filename,36)
;		IDL>plot_hsi_image,bla.image,bla


PRO plot_hsi_image, image, struct,_extra=_extra
hessi_ct	; I want it !

control={xyoffset:struct.xyoffset,					$
		 pixel_size:struct.pixel_size,				$
		 det_index_mask:struct.det_index_mask,		$
		 a2d_index_mask:struct.a2d_index_mask,		$
		 front_segment:struct.front_segment,		$
		 rear_segment:struct.rear_segment,			$
		 energy_band:struct.energy_band				}
	
info={	absolute_time_range:struct.absolute_time_range,	$
		binned_n_event:struct.binned_n_event			}
	
alg=struct.image_algorithm
		 
hsi_image_plot,image, control, info, alg, _extra=_extra 
END
