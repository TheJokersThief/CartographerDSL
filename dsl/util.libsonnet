{
    local util = self,

    as_array(thing)::
        if std.isArray(thing) then thing else [thing],

    is_empty(value)::
        # nulls are missing completely, therefore empty
        if value == null then true
        else
        # strings, arrays, and objects are empty if they contain no elements
        if std.isString(value) || std.isArray(value) || std.isObject(value) then
            if std.length(value) <= 0 then true else false
        else
            # all other types (numbers, boolean, function) cannot be "empty"
            false,

    default(value, fallback)::
        if util.is_empty(value) then fallback else value,
}
