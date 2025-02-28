# Aegisub-Scripts
Aegisub automation scripts

# Kite Styles Manager v1.4 

## Overview
Kite Styles Manager allows precise control over subtitle styling parameters for different actors in your project. This tool streamlines the process of maintaining consistent visual styles across your subtitles.

## Core Features

### Style Management
- **Actor Selection**: Choose any actor from the dropdown menu to view and edit their current style properties
- **Selective Editing**: Modify only specific color attributes by checking the corresponding "Modify" checkboxes
- **Quick Refresh**: Reset the dialog to display the current stored values for the selected actor

### Applying Changes
- **Store Changes**: Click "Apply" to save modified styles for the current actor (without immediate subtitle updates)
- **Global Update**: Use "Save All" to apply all accumulated style changes to the selected subtitle lines

### Default Values
When left unchanged, these parameters retain their neutral values:
- **Spacing & Position**: Blur, Be, Border, Shadow, XShad, YShad, Fsp = 0
- **Scaling**: FscX, FscY = 100
- **Transparency**: Alpha = &H00& (fully opaque)
- **Colors**: Preserved unless specifically marked for modification

### Project Management
- **Import Styles**: Load previously configured actor styles from an external file
- **Export Styles**: Save your complete set of actor styles for backup or sharing
- **Progressive Workflow**: Changes are stored per actor and only applied to subtitles when "Save All" is clicked

# Froggie Tags

## Description
A versatile Aegisub script that allows you to move ASS tags between the text and effects fields. This script is particularly useful for subtitle editors who need to temporarily store or manipulate tag information separately from the text content.

## Features
- **Extract Tags**: Moves initial tags (enclosed in curly braces) from the text field to the effects field
- **Reinsert Tags**: Moves tags from the effects field back to the text field
- **Automatic Format Conversion**: Converts semicolons (;) to commas (,) when reinserting tags, ensuring proper tag formatting

## Usage
1. Select one or more subtitle lines in Aegisub
2. Run "Froggie Tags/Extract" to move tags to the effects field
3. Edit or manipulate the text content as needed
4. Run "Froggie Tags/Reinsert" to restore the tags to the text field
