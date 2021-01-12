/// @function 
function _Container_Null() constructor { static toString = function() { return "%NULL%" } }
#macro NULL _Container_Null

/// @function iterator_destroy(iterator)
function iterator_destroy(Target_iterator) { Target_iterator._Data = 0; delete Target_iterator }

/// @function container_destroy(container)
function container_destroy(Container) { Container._Data = 0; delete Container }

/// @function less(a, b)
function less(A, B) { return (A < B) }

/// @function Iterator(container)
function Iterator(Parent) constructor {
	/// @function equals_to(other)
	static equals_to = function(Other) { return (_Serial_number == Other._Serial_number
		and _Container == Other._Container and _Index == Other._Index) }

	/// @function not_equals_to(other)
	static not_equals_to = function(Other) { return (_Serial_number != Other._Serial_number
		or _Container != Other._Container or _Index != Other._Index) }

	/// @function vailidate()
	static vailidate = function() { return (_Serial_number == _Container._Serial_number) }

	/// @function set(value)
	static set = function(Value) {
		if vailidate() {
			_Container._Data[_Index] = Value
		}
		_Data[_Index] = Value
	}
	
	/// @function get()
	static get = function() {
		if vailidate()
			return _Container._Data[_Index]
		else
			return _Data[_Index]
	}

	/// @function set_index(index)
	static set_index = function(Index) { _Index = Index; return self }

	/// @function go_next()
	static go_next = function() {
		if _Index < _Size - 1
			_Index++
		return self
	}

	/// @function go_previous()
	static go_previous = function() {
		if 0 < _Index
			_Index--
		return self
	}

	_Container = weak_ref_create(Parent)
	_Size = 0
	var NewSize = Parent._Size
	if 0 < NewSize {
		_Data = array_create(NewSize)
		_Size = NewSize
		array_copy(_Data, 0, Parent._Data, 0, _Size)
	} else {
		_Data = undefined
	}
	_Index = 0
	_Serial_number = Parent._Serial_number
}

/// @function List()
function List() constructor {
	/// @function raw_data()
	static raw_data = function() { return _Data }

	/// @function get_size()
	static get_size = function() { return _Size }

	/// @function get_capacity()
	static get_capacity = function() { return _Capacity }

	/// @function is_empty()
	static is_empty = function() { return (_Size == 0) }

	/// @function clear()
	static clear = function() { _Serial_change(); _Size = 0 }

	/// @function resize(size)
	static resize = function(Size) {
		if Size != _Size {
			if Size < _Size {  // reduce
				array_resize(_Data, Size)
			}
			_Capacity_ensure(Size)
			_Size = Size
		}
	}

	/// @function reserve(size)
	static reserve = function(Size) { if _Capacity < Size _Capacity_ensure(Size) }

	/// @function shrink_to_fit()
	static shrink_to_fit = function() { _Capacity_set(max(1, _Size)) }

	/// @function at(index)
	static at = function(Index) { return (0 < _Size and Index < _Size ? _Data[Index] : NULL) }

	/// @function front()
	static front = function() { return (0 < _Size ? _Data[0] : NULL) }

	/// @function back()
	static back = function() { return (0 < _Size ? _Data[_Size - 1] : NULL) }

	/// @function first()
	static first = function() { return (new Iterator(self)) }

	/// @function last()
	static last = function() { return (new Iterator(self).set_index(_Size)) }

	/// @function set_at(index, value)
	static set_at = function(Index, Value) {
		if Index < _Size {
			_Data[Index] = Value
		}
		return self
	}

	/// @function push_back(value)
	static push_back = function(Value) {
		if 1 < argument_count {
			_Capacity_new_ensure(argument_count)
			for (var i = 0; i < argument_count; ++i)
				_Element_add(argument[i])
		} else {
			_Element_add(Value)
		}
		return self
	}

	/// @function erase_at(index)
	static erase_at = function(Index) {
		if _Size <= 0 or is_undefined(Index) or is_nan(Index)
			return NULL

		if is_struct(Index) {
			_Serial_change()
			var Number = Index._Index
			array_delete(_Data, Number, 1)
			return (new Iterator(self).set_index(Number))
		} else {
			if Index < 0 or _Size <= Index
				return NULL
			_Serial_change()
			array_delete(_Data_, Index, 1)
			return (new Iterator(self).set_index(_Size))
		}
	}

	/// @function erase(begin, end)
	static erase = function(First, Last) {
		if _Size <= 0
			return NULL

		var FirstIndex = (is_struct(First) ? First._Index : First)
		var LastIndex = (is_struct(Last) ? Last._Index : Last)
		_Check_range(FirstIndex, LastIndex)

		_Serial_change()
		var Count = LastIndex - FirstIndex
		_Size -= Count
		if 0 == _Size {
			_Data = 0 // deletes _Data
			_Data = []
			_Capacity = 1
			return undefined
		} else {
			array_delete(_Data, FirstIndex, Count)
			_Capacity -= Count
			return (new Iterator(self).set_index(FirstIndex))
		}
	}

	/// @function pop_back()
	static pop_back = function() {
		if 0 < _Size {
			_Serial_change()
			var Result = _Data[_Size - 1]
			_Size--
			return Result
		} else {
			return NULL
		}
	}

	/// @function sort(begin, end, [comparator=less])
	static sort = function(First, Last) {
		if _Size <= 0
			exit

		var FirstIndex = (is_struct(First) ? First._Index : First)
		var LastIndex = (is_struct(Last) ? Last._Index : Last)
		_Check_range(FirstIndex, LastIndex)

		var Comparator = (2 < argument_count ? argument[2] : less)
		var Range = LastIndex - FirstIndex
		if Range == 1 {
			exit
		} else {
			var Temp = array_create(Range)
			array_copy(Temp, 0, _Data, FirstIndex, Range)
			array_sort(Temp, Comparator)
			array_copy(_Data, FirstIndex, Temp, 0, Range)
			Temp = 0
		}
	}

	/// @function 
	static _Check_range = function(First, Last) {
		if First < 0 or Last < 0 or _Size <= First or _Size < Last
			throw "An error occured when erasing on range(" + string(First) + ", " + string(Last) + ")\nOut of bound."
		else if Last < First
			throw "An error occured when erasing on range(" + string(First) + ", " + string(Last) + ")\nFirst is greater then Last."
	}

	/// @function 
	static _Serial_change = function() { _Serial_number++ }

	/// @function 
	static _Capacity_set = function(Size) {
		if _Capacity != Size {
			array_resize(_Data, Size)
			if _Capacity < Size {
				for (var i = 0; i < Size - _Capacity; ++i)
					_Data[_Capacity + i] = undefined
			}
			_Capacity = Size
		}
	}

	/// @function 
	static _Capacity_ensure = function(StoreSize) { _Capacity_set(ceil(StoreSize / 4) * 4 + 8) }

	/// @function 
	static _Capacity_new_ensure = function(Count) {
		var NewCap = _Size + Count
		if _Capacity <= NewCap
			_Capacity_ensure(NewCap)
	}

	/// @function 
	static _Element_add = function(Value) {
		if _Capacity <= _Size
			_Capacity_ensure(_Size)
		_Data[_Size++] = Value
	}

	_Serial_number = 0
	_Data = []
	_Capacity = 8
	_Size = 0
}
