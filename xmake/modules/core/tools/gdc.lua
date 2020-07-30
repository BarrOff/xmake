--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-2020, TBOOX Open Source Group.
--
-- @author      ruki, BarrOff
-- @file        gdc.lua
--

inherit("dmd")

-- make the optimize flag
function nf_optimize(self, level)
    local maps =
    {
        fast        = "-O"
    ,   faster      = "-O -frelease"
    ,   fastest     = "-O -frelease -fbounds-check=off"
    ,   smallest    = "-O -frelease -fbounds-check=off"
    ,   aggressive  = "-O -frelease -fbounds-check=off"
    }
    return maps[level]
end

-- make the strip flag
function nf_strip(self, level)
    local maps = 
    {   
        debug       = "-S"
    ,   all         = "-s"
    }
    return maps[level] 
end

-- make the warning flag
function nf_warning(self, level)
    local maps =
    {
        none        = "-w"
    ,   less        = "-Wall"
    ,   more        = "-Wall"
    ,   all         = "-Wall"
    ,   everything  = "-Wall -Wdeprecated -Wextra"
    ,   error       = "-Werror"
    }
    return maps[level]
end

-- make the vector extension flag
function nf_vectorext(self, extension)
    local maps =
    {
        mmx   = "-mmmx"
    ,   sse   = "-msse"
    ,   sse2  = "-msse2"
    ,   sse3  = "-msse3"
    ,   ssse3 = "-mssse3"
    ,   avx   = "-mavx"
    ,   avx2  = "-mavx2"
    }
    return maps[extension]
end

-- make the link flag
function nf_link(self, lib)
    return "-l" .. lib
end

-- make the syslink flag
function nf_syslink(self, lib)
    return nf_link(self, lib)
end

-- make the linkdir flag
function nf_linkdir(self, dir)
    return "-L" .. os.args(dir)
end

-- make the rpathdir flag
function nf_rpathdir(self, dir)
    dir = path.translate(dir)
    if self:has_flags("-rpath=" .. dir, "ldflags") then
        return "-rpath=" .. os.args(dir:gsub("@[%w_]+", function (name)
            local maps = {["@loader_path"] = "$ORIGIN", ["@executable_path"] = "$ORIGIN"}
            return maps[name]
        end))

    elseif self:has_flags("-rpath " .. dir, "ldflags") then
        return "-rpath " .. os.args(dir:gsub("%$ORIGIN", "@loader_path"))
    end
end

-- make the link arguments list
function linkargv(self, objectfiles, targetkind, targetfile, flags)

    -- add rpath for dylib (macho), e.g. -install_name @rpath/file.dylib
    local flags_extra = {}
    if targetkind == "shared" and is_plat("macosx") then
        table.insert(flags_extra, "-install_name")
        table.insert(flags_extra, "@rpath/" .. path.filename(targetfile))
    end

    -- init arguments
    return self:program(), table.join(flags, flags_extra, "-o" .. targetfile, objectfiles)
end

-- link the target file
function link(self, objectfiles, targetkind, targetfile, flags)

    -- ensure the target directory
    os.mkdir(path.directory(targetfile))

    -- link it
    os.runv(linkargv(self, objectfiles, targetkind, targetfile, flags))
end

-- make the compile arguments list
function compargv(self, sourcefile, objectfile, flags)
    return self:program(), table.join("-c", flags, "-o" .. objectfile, sourcefile)
end

-- compile the source file
function compile(self, sourcefile, objectfile, dependinfo, flags)

    -- ensure the object directory
    os.mkdir(path.directory(objectfile))

    -- compile it
    os.runv(compargv(self, sourcefile, objectfile, flags))
end

