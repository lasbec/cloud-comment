const std = @import("std");

pub const PCloudError = error{
    Unauthorized,
    NotFound,
    UpstreamFailure,
};

pub const Note = struct {
    id: []const u8,
    title: []const u8,
    markdown: []const u8,
};

pub const PCloudApi = struct {
    context: *anyopaque,
    listNotesFn: *const fn (*anyopaque, std.mem.Allocator) PCloudError![]Note,
    readNoteFn: *const fn (*anyopaque, std.mem.Allocator, []const u8) PCloudError!Note,
    writeNoteFn: *const fn (*anyopaque, Note) PCloudError!void,

    pub fn listNotes(self: PCloudApi, allocator: std.mem.Allocator) PCloudError![]Note {
        return self.listNotesFn(self.context, allocator);
    }

    pub fn readNote(self: PCloudApi, allocator: std.mem.Allocator, id: []const u8) PCloudError!Note {
        return self.readNoteFn(self.context, allocator, id);
    }

    pub fn writeNote(self: PCloudApi, note: Note) PCloudError!void {
        return self.writeNoteFn(self.context, note);
    }
};
