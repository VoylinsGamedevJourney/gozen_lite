#pragma once

#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

class Video : public Resource {
	GDCLASS(Video, Resource);

private:

public:

	inline bool print_something(String a_text) {
		UtilityFunctions::print_rich(
			String("[b]{text}[/b]").replace("{text}", a_text));
		return true;
	}


protected:

	static inline void _bind_methods() {
		ClassDB::bind_method(
			D_METHOD("print_something", "a_text"),
			&Video::print_something);
	}

};
