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
-- Copyright (C) 2015-present, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        xmake.lua
--

-- update vsxmake project automatically
--
-- @code
-- add_rules("plugin.vsxmake.autoupdate")
-- target("test")
--     set_kind("binary")
--     add_files("src/*.c")
-- @endcode
--
rule("plugin.vsxmake.autoupdate")
    before_build(function (target)

        -- imports
        import("core.project.depend")
        import("core.project.project")
        import("core.base.task")

        -- run only once for all xmake process in vs
        local tmpfile = os.tmpfile(path.join(os.projectdir(), "plugin.vsxmake.autoupdate"))
        local lockfile = io.openlock(tmpfile .. ".lock")
        if lockfile:trylock() then
            if os.getenv("XMAKE_IN_VSTUDIO") then
                depend.on_changed(function ()
                    -- we use task instead of os.exec("xmake") to avoid the project lock
                    print("update vsxmake project ..")
                    task.run("project", {kind = "vsxmake"})
                    print("update vsxmake project ok")
                end, {dependfile = tmpfile .. ".d",
                      files = project.allfiles(),
                      values = target:sourcefiles()})
            end
            lockfile:close()
        end
    end)

