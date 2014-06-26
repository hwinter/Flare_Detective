;removes any occurrences of a single element (referred to by its value, not its subscript) from a 1-D array.

FUNCTION remove_element, arr, elem
	ss=WHERE(arr NE elem)
	IF ss[0] EQ -1 THEN RETURN,-1 ELSE RETURN,arr[ss]
END
