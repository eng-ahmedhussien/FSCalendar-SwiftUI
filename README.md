# FSCalendar-SwiftUI

## Overview

This repository contains a custom calendar view implemented in SwiftUI,
It leverages the FSCalendar library to provide a flexible and visually customizable calendar experience.
## Features

Allows users to select and view date ranges relevant to their data model.
Enforces a maximum allowed range of 7 days for date selection.
Provides options for customizing colors and appearance.
Updates automatically based on changes in the underlying data model.

## Usage

Create an instance of the data model class to hold your data.
Use the CustomCalendar view in your SwiftUI view hierarchy, binding it to the data model.
Customize the behavior as needed using the model's properties.
## Customization Options

isEnableEditing: Toggle free date selection or restrict to 7-day range.
dateRanges: Set predefined date ranges to display.
getColorFor(date:): Define custom colors for specific dates.

FSCalendar (https://github.com/WenchaoD/FSCalendar)
