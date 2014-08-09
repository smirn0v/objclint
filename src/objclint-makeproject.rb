#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'
require 'pathname'

OBJCLINT_NAME_PREFIX = ".objclint_project_"

def objclint_name(name)
    return File.dirname(name)+File::SEPARATOR+OBJCLINT_NAME_PREFIX+File.basename(name)
end

if ARGV.length != 2
    puts "Usage: #{File.basename($0)} <project or workspace> <target>"
    exit(1)
end

p_or_w = ARGV[0]
target = ARGV[1]
project = nil

absolute_current_path = Pathname.new(File.absolute_path("./"))

if !File.exists?(p_or_w)
    puts "Can't find '#{p_or_w}' file"
    exit(2)
end

if p_or_w.end_with?(".xcworkspace")
    objclint_workspace_path = objclint_name(p_or_w)
    orig_workspace = Xcodeproj::Workspace.new_from_xcworkspace(p_or_w)
    objclint_workspace = Xcodeproj::Workspace.new()
    orig_workspace.schemes.each { |key,value|
        if key == target
            objclint_project_path = objclint_name(value)
            objclint_project_path = File.absolute_path(objclint_project_path)
            objclint_project_path = Pathname.new(objclint_project_path).relative_path_from(absolute_current_path).to_s

            FileUtils.copy_entry(value, objclint_project_path, remove_destination = true)
            project = Xcodeproj::Project.open(objclint_project_path)

            orig_workspace.file_references.each { |ref|
                if File.absolute_path(ref.path) == File.absolute_path(value)
                    objclint_workspace << objclint_project_path
                else
                    objclint_workspace << ref.path
                end
            }
            objclint_workspace.save_as(objclint_workspace_path)
        end
    }
else
    objclint_project_path = objclint_name(p_or_w)
    FileUtils.copy_entry(p_or_w, objclint_project_path, remove_destination = true)
    project = Xcodeproj::Project.open(objclint_project_path)
    if project 
end
