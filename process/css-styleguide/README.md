# Meilisearch demos style guide

Meilisearch Demos style guide contains a set of common UI elements along with their CSS for any developer to choose from to maintain consistent styling across the demos created for Meilisearch. If you are interested in creating a demo, you can refer to the common UI components and use those in your project.

## About the style guides

The style guide consists of a number of common UI components such as buttons, headings, search inputs that can be included while creating the UI of a project.

## Components included

- Button
- Inputs
- Modal
- Search Input
- Tags
- Typography: headings and body text

## Brief examples and usage

### Button

1. The base class for styling a button is `.btn`. It will set some basic stylings to the button.
2. Style support: change the color styling of the button by using classes like `.btn-dodger-blue`

```sh
<button class="btn btn-dodger-blue" type="button">Click Me</button>
```

Output :

![Screenshot from 2022-07-16 17-23-48](https://user-images.githubusercontent.com/64376712/179353830-490f0c28-f3d3-4059-a039-df657be396ba.png)


### Input

1.  The parent class `.input` will assign some basic styling to the input.
2.  Labels can also be styled depending upon various needs. The classes are `.input--label`, `.input--message`, `.input--error`, and `.input--message-error`

```sh
<input
  type="text"
  class="input input--label"
  placeholder="Write something"
/>
```

Output :

![Screenshot from 2022-07-16 17-41-11](https://user-images.githubusercontent.com/64376712/179354416-16d343f4-5d81-44c3-82bc-2e6f3f88f4ba.png)

### Modal

1. To render the content in a modal window, wrap it inside the parent element such as `div` and give it the `.modal` class.

```sh
<div class="modal">
    <div class="typography title-l">This is a modal</div>
</div>
```

Output :

![Screenshot from 2022-07-11 15-08-37](https://user-images.githubusercontent.com/64376712/178236255-d999514e-50f9-4960-9958-497ce207d1ed.png)

### Search input

1. The class `.input-search` will give styling to the search input and will also handle the events like active, focus and hover.

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

1. Choose the styling of the tag depending upon the requirements by using different classes.
   Classes list :
   1. `.tag` (required - base class name)
   2. `.tag-sucess`
   3. `.tag-process`
   4. `.tag-error`
   5. `.tag-loader`
   6. `.tag-delete`

```sh
<span class="tag tag-success typography body-s">active</span>
```

Output :

![Screenshot from 2022-07-11 15-09-14](https://user-images.githubusercontent.com/64376712/178236349-c88eeb11-ec81-4da0-90c9-54ab722d9efc.png)

### Typography: headings and body text

#### Headings
1. The base class for styling the heading is `.title`. It will assign font styling to text.
2. Classes to change heading size include `.title-xl` `.title-l` `.title-m` `.title-s`, `.title-xs`, `.title-caps`, and `.title-caps-xs`.

#### Body text
1. The base class for styling body text is `.body`. It will assign font styling to text.
2. Classes to change body text size include `.body-l` `.body-m` `.body-s`, and `.body-xs`.
3. Class `.text-bold` will give a weight of 600 to body text.
4. To underline text, use the `.text-underline` class.

#### Colors
To apply basic colors to text you can use the following classes:
- `.text-valhalla-500`, `.text-valhalla-300`, `.text-valhalla-100`
- `.text-ashes-900`, `.text-ashes-500`

To highlight text, you can use the following classes:
- `.text-hot-pink-500`, `.text-hot-pink-400`
- `.text-dodger-blue-500`, `.text-dodger-blue-400`

Technical colors can be applied with the following classes:
- `.text-peppermint-500`
- `.text-candlelight-500`
- `.text-watermelon-500`

```sh
<h1 class="title title-xl text-valhalla-500">Title XL</h1>
``` 

Output :

![Screenshot from 2022-07-16 17-40-45](https://user-images.githubusercontent.com/64376712/179354378-c98ae1ec-3331-472d-94dd-08a8863c210a.png)
