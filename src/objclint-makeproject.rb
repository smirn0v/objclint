#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'
require 'pathname'

OBJCLINT_NAME_PREFIX = ".objclint_"

def objclint_name(name)
    return File.dirname(name)+File::SEPARATOR+OBJCLINT_NAME_PREFIX+File.basename(name)
end

def objclint_add_bs(bs,name,value)
    old = bs[name] || []
    old << value
    bs[name] = old
end

def objclint_remove_bp(target,cls)
    resource_phase = target.build_phases.objects.select{|phase| phase.kind_of?(cls)}.first
    if resource_phase
        target.build_phases.delete(resource_phase)
    end
end

if ARGV.length != 2
    puts "Usage: #{File.basename($0)} <project or workspace> <target>"
    exit(1)
end

p_or_w = ARGV[0]
target_name = ARGV[1]
project = nil
target = nil

absolute_current_path = Pathname.new(File.absolute_path("./"))

if !File.exists?(p_or_w)
    puts "Can't find '#{p_or_w}' file"
    exit(2)
end

if p_or_w.end_with?(".xcworkspace")
    objclint_workspace_path = objclint_name(p_or_w)
    orig_workspace = Xcodeproj::Workspace.new_from_xcworkspace(p_or_w)
    objclint_workspace = Xcodeproj::Workspace.new()

    orig_workspace.file_references.each { |ref|
        local_project = Xcodeproj::Project.open(ref.path)
        should_add_ref = true 
        local_project.targets.each { |t|
            if t.name == target_name
                objclint_project_path = objclint_name(ref.path)
                objclint_project_path = File.absolute_path(objclint_project_path)
                objclint_project_path = Pathname.new(objclint_project_path).relative_path_from(absolute_current_path).to_s

                FileUtils.copy_entry(ref.path, objclint_project_path, remove_destination = true)

                objclint_workspace << objclint_project_path
                project = Xcodeproj::Project.open(objclint_project_path)
                should_add_ref = false
            end
        }
        if should_add_ref
            objclint_workspace << ref.path
        end
    }
    objclint_workspace.save_as(objclint_workspace_path)

else
    objclint_project_path = objclint_name(p_or_w)
    FileUtils.copy_entry(p_or_w, objclint_project_path, remove_destination = true)
    project = Xcodeproj::Project.open(objclint_project_path)
    if !project.targets.select{|t| t.name == target_name}
        project = nil
    end
end

if !project
    puts "Can't find target '#{target}'"
    exit(3)
end

target = project.targets.select{|tn| tn.name == target_name}.first

objclint_remove_bp(target,Xcodeproj::Project::Object::PBXResourcesBuildPhase)
objclint_remove_bp(target,Xcodeproj::Project::Object::PBXFrameworksBuildPhase)

target.build_configurations.each { |bc| 
    bs = bc.build_settings

    objclint_add_bs(bs,'GCC_PREPROCESSOR_DEFINITIONS','__objclint')
   # objclint_add_bs(bs,'CCFLAGS','-objclint-fake-cc')
   # objclint_add_bs(bs,'CXXFLAGS','-objclint-fake-cxx')

    bs['CODE_SIGN_IDENTITY'] = ""
    bs['CODE_SIGNING_REQUIRED'] = "NO"
    bs['CODE_SIGN_ENTITLEMENTS'] = ""
    
    bs['CC'] = 'objclint-pseudo-compiler'
    bs['CXX'] = 'objclint-pseudo-compiler'

    bs['GCC_PRECOMPILE_PREFIX_HEADER'] = "NO"
    bs['GCC_GENERATE_DEBUGGING_SYMBOLS'] = "NO"
    
}

project.save
