# Meilisearch Demos Style Guide

Meilisearch Demos style guide contains a set of common UI elements along with their CSS for any developer to choose from to maintain consistent styling across the demos that are created for Meilisearch. In case you are interested in creating a demo, you can refer to the common UI components and use those in your project.

## About the Style Guides

The style guide consists of a number of common UI components such as buttons, headings, search inputs that can be included while creating the UI of a project.

## Components Included

- Button
- Heading
- Inputs
- Modal
- Search Input
- Tags

## Brief Examples and Usage

### Button

1. The Base class for styling the button is `.btn` that will set some basics stylings to button.
2. Style Support : Change the color styling of the button by using classes like `.btn-dodger-blue`

```sh
<button class="btn btn-dodger-blue" type="button">Click Me</button>
```

Output :

![Screenshot from 2022-07-11 15-07-19](https://user-images.githubusercontent.com/64376712/178236035-083e0575-eb6c-4e13-8952-c19c9270cd8e.png)

### Heading

1. The Base class for styling the heading is `.typography` that will assign font-styling to text.
2. Classes to change text and size includes `.title-xl` `.title-l` `.title-m` `.title-s`

```sh
<h1 class="typography title-xl">This is Title XL</h1>
```

Output :

![Screenshot from 2022-07-11 15-07-45](https://user-images.githubusercontent.com/64376712/178236110-32d14e90-9684-43b7-9ed3-c0776767aba9.png)

### Input

1.  The parent class `.input` will assign some basics styling to the input.
2.  Styling can also be given to labels depending upon varoius needs, some of the classes are `.input--label` `.input--message` `.input--message-error`

```sh
<input
  type="text"
  class="input input--label"
  placeholder="Write something"
/>
```

Output :

![Screenshot from 2022-07-11 15-08-08](https://user-images.githubusercontent.com/64376712/178236190-07504bfa-ced5-4c71-bd12-b05109e24884.png)

### Modal

1. To use Modal, Warp the content inside parent element such as `div` and give it `.modal` class, this will render the content in Modal.

```sh
<div class="modal">
    <div class="typography title-l">This is a modal</div>
</div>
```

Output :

![Screenshot from 2022-07-11 15-08-37](https://user-images.githubusercontent.com/64376712/178236255-d999514e-50f9-4960-9958-497ce207d1ed.png)

### Search Input

1. The class `.input-search` will give styling to search input and will also handles the events like active, focus and hover.

```sh
<input
    type="search"
    placeholder="Search something"
    class="input input-search"
 />
```

Output :

![Screenshot from 2022-07-11 15-09-00](https://user-images.githubusercontent.com/64376712/178236293-3bb79c1a-8960-4634-847f-991a245f7f35.png)

### Tag

1. Choose the styling of the tag depending upon the requirements by using different classes like
   `.tag-sucess` `.tag-process` along with `.tag`

```sh
<span class="tag tag-success typography body-s">active</span>
```

Output :

![Screenshot from 2022-07-11 15-09-14](https://user-images.githubusercontent.com/64376712/178236349-c88eeb11-ec81-4da0-90c9-54ab722d9efc.png)
