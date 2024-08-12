class_name DataManager extends Node
## Creates a way to easily save and load documentation
##
## Extend from the class `DataManager` and use the `save_data` and `load_data`
## functions. All normal variables will be saved except for variables starting
## with an underscore and const variables. [br][br]
## 
## All return values are errors which are inside of [enum @GlobalScope.Error]



## Run this function from anywhere in your script which extends with the path
## as the argument. This saves all normal variables, but not the ones which
## start with an underscore.
func save_data(a_path: String) -> int:
	var l_file: FileAccess = FileAccess.open(a_path, FileAccess.WRITE)
	if FileAccess.get_open_error():
		return ERR_FILE_CANT_OPEN

	var l_data: Dictionary = {}

	for l_property: Dictionary in get_property_list():
		var l_usage: int = l_property.usage
		var l_name: String = l_property.name

		if ((l_usage == 4096 || l_usage == 4102) && l_name[0] != '_'):
			l_data[l_name] = get(l_name)

	l_file.store_string(var_to_str(l_data))
	if l_file.get_error() != 0:
		return l_file.get_error()

	l_file.close()
	return OK


## Same as [method DataManager.save_data], but for saving compressed data.
## For a_compression use [enum FileAccess.CompressionMode].
func save_data_compressed(a_path: String, a_compression: int) -> int:
	var l_file: FileAccess = FileAccess.open_compressed(a_path, FileAccess.WRITE, a_compression)
	if FileAccess.get_open_error():
		return ERR_FILE_CANT_OPEN

	var l_data: Dictionary = {}

	for l_property: Dictionary in get_property_list():
		var l_usage: int = l_property.usage
		var l_name: String = l_property.name

		if ((l_usage == 4096 || l_usage == 4102) && l_name[0] != '_'):
			l_data[l_name] = get(l_name)

	l_file.store_string(var_to_str(l_data))
	if l_file.get_error() != 0:
		return l_file.get_error()

	l_file.close()
	return OK


## Same as [method DataManager.save_data], but for saving encrypted data.
## [b]Note:[/b] The provided key must be 32 bytes long.
func save_data_encrypted(a_path: String, a_key: PackedByteArray) -> int:
	var l_file: FileAccess = FileAccess.open_encrypted(a_path, FileAccess.WRITE, a_key)
	if FileAccess.get_open_error():
		return ERR_FILE_CANT_OPEN

	var l_data: Dictionary = {}

	for l_property: Dictionary in get_property_list():
		var l_usage: int = l_property.usage
		var l_name: String = l_property.name

		if ((l_usage == 4096 || l_usage == 4102) && l_name[0] != '_'):
			l_data[l_name] = get(l_name)

	l_file.store_string(var_to_str(l_data))
	if l_file.get_error() != 0:
		return l_file.get_error()

	l_file.close()
	return OK


## Same as [method DataManager.save_data], but for saving encrypted data with a pass.
func save_data_encrypted_with_pass(a_path: String, a_pass: String) -> int:
	var l_file: FileAccess = FileAccess.open_encrypted_with_pass(a_path, FileAccess.WRITE, a_pass)
	if FileAccess.get_open_error():
		return ERR_FILE_CANT_OPEN

	var l_data: Dictionary = {}

	for l_property: Dictionary in get_property_list():
		var l_usage: int = l_property.usage
		var l_name: String = l_property.name

		if ((l_usage == 4096 || l_usage == 4102) && l_name[0] != '_'):
			l_data[l_name] = get(l_name)

	l_file.store_string(var_to_str(l_data))
	if l_file.get_error() != 0:
		return l_file.get_error()

	l_file.close()
	return OK


## Use this function for loading in all the variables which do not start with
## an underscore as those values don't get saved.
func load_data(a_path: String) -> int:
	if (FileAccess.file_exists(a_path)):
		var l_file: FileAccess = FileAccess.open(a_path, FileAccess.READ)
		if FileAccess.get_open_error():
			return ERR_FILE_CANT_OPEN

		var l_data: Dictionary = str_to_var(l_file.get_as_text())

		for l_key: String in l_data.keys():
			set(l_key, l_data[l_key])

		if l_file.get_error() != 0:
			return l_file.get_error()

		l_file.close()
		return OK
	return ERR_FILE_NOT_FOUND


## Same as [method DataManager.load_data], but for loading compressed data.
## For a_compression use [enum FileAccess.CompressionMode].
func load_data_compressed(a_path: String, a_compression: int) -> int:
	if (FileAccess.file_exists(a_path)):
		var l_file: FileAccess = FileAccess.open_compressed(a_path, FileAccess.READ, a_compression)
		if FileAccess.get_open_error():
			return ERR_FILE_CANT_OPEN

		var l_data: Dictionary = str_to_var(l_file.get_as_text())

		for l_key: String in l_data.keys():
			set(l_key, l_data[l_key])

		if l_file.get_error() != 0:
			return l_file.get_error()

		l_file.close()
		return OK
	return ERR_FILE_NOT_FOUND


## Same as [method DataManager.load_data], but for loading encrypted data.[br]
## [b]Note:[/b] The provided key must be 32 bytes long.
func load_data_encrypted(a_path: String, a_key: PackedByteArray) -> int:
	if (FileAccess.file_exists(a_path)):
		var l_file: FileAccess = FileAccess.open_encrypted(a_path, FileAccess.READ, a_key)
		if FileAccess.get_open_error():
			return ERR_FILE_CANT_OPEN

		var l_data: Dictionary = str_to_var(l_file.get_as_text())

		for l_key: String in l_data.keys():
			set(l_key, l_data[l_key])

		if l_file.get_error() != 0:
			return l_file.get_error()

		l_file.close()
		return OK
	return ERR_FILE_NOT_FOUND


## Same as [method DataManager.load_data], but for loading encrypted data with a pass.
func load_data_encrypted_with_pass(a_path: String, a_pass: String) -> int:
	if (FileAccess.file_exists(a_path)):
		var l_file: FileAccess = FileAccess.open_encrypted_with_pass(a_path, FileAccess.READ, a_pass)
		if FileAccess.get_open_error():
			return ERR_FILE_CANT_OPEN

		var l_data: Dictionary = str_to_var(l_file.get_as_text())

		for l_key: String in l_data.keys():
			set(l_key, l_data[l_key])

		if l_file.get_error() != 0:
			return l_file.get_error()

		l_file.close()
		return OK
	return ERR_FILE_NOT_FOUND

