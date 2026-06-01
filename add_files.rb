require 'xcodeproj'

project_path = 'luxury.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Add EditBoutiqueViewModel.swift
group = project.main_group.find_subpath(File.join('luxury', 'Core', 'Shared', 'ViewModels'), true)
file_ref = group.new_reference('EditBoutiqueViewModel.swift')
project.targets.first.add_file_references([file_ref])

# Add EditBoutiqueView.swift
group = project.main_group.find_subpath(File.join('luxury', 'Core', 'Shared', 'Views'), true)
file_ref = group.new_reference('EditBoutiqueView.swift')
project.targets.first.add_file_references([file_ref])

# Add ICProfileView.swift
group = project.main_group.find_subpath(File.join('luxury', 'Core', 'InventoryController', 'Profile', 'Views'), true)
file_ref = group.new_reference('ICProfileView.swift')
project.targets.first.add_file_references([file_ref])

project.save
puts "Successfully added files to the project."
