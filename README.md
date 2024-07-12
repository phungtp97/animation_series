
# Animation Series

An animation series project that demonstrates the use of simple/complex use cases of Animation/Effects in Flutter.

## Overview

This repository showcases various animation demos using Flutter. Each demo illustrates different animation techniques and effects that can be implemented in Flutter applications.

## Demos

### 1. Drag and Transform
Demonstrate a drag-and-drop feature with animations. Items can be dragged from a horizontal list and dropped into a vertical list. When an item is dropped, an animated transition adds it to the vertical list, and a color-changing animation is applied to indicate its new state.
<img src="https://i.imgur.com/m7X8kQf.gif" width="200">

### 2. Messenger Gradient Background Effects
Demonstrate a chat application with a gradient background and color-filtered message bubbles which are just like Facebook Mesenger.
<img src="https://i.imgur.com/ekANNin.gif" width="200">

### 3. Splash Like Animation
Demonstrate a "splash-like" animation triggered by tapping an image or an icon. When liked, the animation controller drives the appearance of a red border and a heart animation using Lottie. The `ColorTween` and `BorderRadiusTween` animations enhance visual feedback by transitioning colors and shapes during the interaction.
<img src="https://i.imgur.com/q3GOyXH.gif" width="200">

### 4. HeroTag + Animated Page Entry
Define a `PageEntryAnimationMixin` to add entry animations to any `StatefulWidget`. The mixin provides slide, fade, and scale transitions using an `AnimationController`. In the `DemoAnimatedPageEntry`, tapping the `RegisterTextField` navigates to a new page (`AnimatedPageEntry`) with a slide transition for a child widget, enhancing the visual experience of entering the page.
<img src="https://i.imgur.com/pm5Ss3l.gif" width="200">

### 5. Radar chart animation
Animate a dynamic radar chart using an `AnimationController`. The `RadarChartPainter` draws concentric polygons and axes, while the `RadarChartStatsPainter` animates the chart's data points in a circular motion using a gradient stroke. The animation progresses through specified points, creating a dynamic visualization as the radar chart fills based on the provided data.
<img src="https://i.imgur.com/cOgHYSI.gif" width="200">

### 6. Svg Path Advanced Interaction
Demonstrate advanced interaction with SVG paths. It parses SVG content, extracts paths and rectangles, and renders them on the screen. Users can interact with the SVG paths, which are highlighted upon selection. The `CustomPainter` and `CustomClipper` classes handle the drawing and interaction logic, providing visual feedback by changing the color and displaying the ID of the selected path.
<img src="https://i.imgur.com/vWerPwp.gif" width="200">

### 7. Staggered Animation Dialog
Defines a `StaggeredAnimationDialog`, a widget that displays a dialog with staggered animations. The animations include a sweep, fade, scale, border radius, size, and offset transition, controlled by an `AnimationController`. The dialog shows a loading animation initially and transitions to a success animation. Upon success, a button appears, allowing the user to close the dialog. The animations create a dynamic and engaging user experience.
<img src="https://i.imgur.com/BIl4adG.gif" width="200">

### To be continue

## Getting Started

To get started with these animations, clone the repository and run the Flutter project:

```bash
git clone https://github.com/phungtp97/animation_series.git
cd animation_series
flutter run
