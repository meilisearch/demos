# Meilisearch demos theme

Meilisearch Demos theme contains a set of common UI elements along with their CSS for any developer to choose from to maintain consistent styling across the demos created for Meilisearch. If you are interested in creating a demo, you can refer to the common UI components and use those in your project.

## About the theme

This theme is based on the [Meilisearch Design System](https://www.figma.com/file/XXmUvsZzfZBKt1i2v12wf4/Design-System?node-id=1504%3A282) and the [Meilisearch Guide to Design a Demo](https://www.figma.com/file/YUqMlOmApYd0D2aitPyDce/Guide-to-design-a-demo?node-id=2%3A8) (_private links_).

## Components and utilities included

- [Button](#button)
- [Input](#input)
- [Logos](#Logos)
- [Modal](#modal)
- [Search Form](#search-form)
- [Tag](#tag)
- [Typography: headings and body text](#typography-headings-and-body-text)
- [Spacing stylesheet](#spacing-stylesheet)

## Usage

### Button

1. The base class for styling a button is `.btn`.
2. Change the color styling of the button by using the following classes:
- `.btn-dodger-blue` 
- `.btn-hot-pink`
- `.btn-lila` 
- `.btn-turquoise`
- `.btn-watermelon`
- `.btn-peppermint`
- `.btn-candlelight`

```html
<button class="btn btn-dodger-blue" type="button">Button</button>
```

3. You can create a secondary button by adding the `.btn-secondary` class

```html
<button class="btn btn-dodger-blue btn-secondary" type="button">Button</button>
```

4. To change the size of the button, you can add `.btn-sm` or `.btn-lg` to the class list.

```html
<button class="btn btn-sm btn-dodger-blue" type="button">Button</button>
```


Output :

<img width="50%" alt="Capture d’écran 2022-08-23 à 10 33 08" src="https://user-images.githubusercontent.com/48251481/186461703-49f5d19b-128e-4b28-9348-f1838c69ab74.png">


### Input

1.  The parent class `.input` will assign some basic styling to the input.
2.  Labels can also be styled depending upon various needs. The classes are `.input--label`, `.input--message`, `.input--error`, and `.input--message-error`

```html
<input
  type="text"
  class="input input--label"
  placeholder="Write something"
/>
```

Output :

<img width="311" alt="Capture d’écran 2022-08-23 à 10 34 05" src="https://user-images.githubusercontent.com/48251481/186462336-24f8c55e-29fc-49c8-93c4-e45a90eb1e72.png">

### Modal

1. To render the content in a modal window, wrap it inside the parent element such as `div` and give it the `.modal` class.

```html
<div class="modal">
    <div class="title title-l">This is a modal</div>
</div>
```

Output :

![Screenshot from 2022-07-11 15-08-37](https://user-images.githubusercontent.com/64376712/178236255-d999514e-50f9-4960-9958-497ce207d1ed.png)

### Search form

The search form is composed of 3 elements, each with its own corresponding classes:
1. A form with a `.search-form` class, which gives flex container properties to the form element

2. An input: the base class `.input` assign basic input style to the input. It needs to be combined with `.search-input` to give it a search bar style, adding the magnifier glass to it.

3. A reset button: the base class for styling a reset button is `.search-input-reset`.

```html
  <form class="search-form">
    <input
      type="search"
      placeholder="Search something"
      class="input search-input"
    />
    <button type="reset" class="search-input-reset">
      <!-- Icon here  -->
    </button>
  </form>
```

Output :

<img width="488" alt="Capture d’écran 2022-08-25 à 18 07 31" src="https://user-images.githubusercontent.com/48251481/186716079-47c20b88-f806-4daf-ac2a-95795067ed3e.png">

### Tag

1. Choose the styling of the tag depending upon the requirements by using different classes.
   Classes list:
   1. `.tag` (required - base class name)
   2. `.tag-success`
   3. `.tag-process`
   4. `.tag-loader`
   5. `.tag-error`
   6. `.tag-delete`

  👉 `.tag-loader` is the loader animation and is to be used with `.tag-process`

```html
<span class="tag tag-success body body-s">active</span>
```

Output :

<img width="124" alt="Capture d’écran 2022-08-29 à 14 28 00" src="https://user-images.githubusercontent.com/48251481/187201058-47e4bafe-ca14-4595-87b0-193dfc2f9a5f.png">

### Typography: headings and body text

#### Headings
1. The base class for styling the heading is `.title`. It will assign font styling to text.
2. Classes to change heading size include `.title-xl` `.title-l` `.title-m` `.title-s`, `.title-xs`, `.title-caps`, and `.title-caps-xs`.

#### Body text
1. The base class for styling body text is `.body`. It will assign font styling to text.
2. Classes to change body text size include `.body-l` `.body-m` `.body-s`, and `.body-xs`.
3. Class `.text-bold` will give a weight of 600 to body text.
4. To underline text, use the `.text-underline` class.

💡 Both headings and body text are responsive 

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

```html
<h1 class="title title-xl text-valhalla-500">Title XL</h1>
``` 

Output :

<img width="284" alt="Capture d’écran 2022-08-23 à 10 36 41" src="https://user-images.githubusercontent.com/48251481/186462510-6babff7a-e595-43bf-bdeb-f0270b381907.png">

### Spacing stylesheet
Spacing utilities include margin and padding.
The classes are named using the format {property}{sides}-{size}

Where property is:
- `m` - for classes that set margin
- `p` - for classes that set padding

Where sides is:
- `t` - for classes that set margin-top or padding-top
- `b` - for classes that set margin-bottom or padding-bottom
- `x` - for classes that set both *-left and *-right
- `y` - for classes that set both *-top and *-bottom

Where size is:
- `0` - for classes that remove the margin or padding by setting it to 0
- `1` - for classes that set the margin or padding to 0.25 rem
- `2` - for classes that set the margin or padding to 0.5 rem
- `3` - for classes that set the margin or padding to 0.75 rem
- `4` - for classes that set the margin or padding to 1 rem
- `5` - for classes that set the margin or padding to 1.25 rem

Note that `side` is optional, if you omit it, the property will be applied to all sides.

Example:

```html
 <div class="m-4">Applies a margin of 1rem to all sides</div>
 <div class="mt-4">Applies a margin of 1rem to the top side</div>
 <div class="mb-4">Applies a margin of 1rem to the bottom side</div>
 <div class="my-4">Applies a margin of 1rem to the top and bottom sides</div>
 <div class="mr-4">Applies a margin of 1rem to the right side</div>
 <div class="ml-4">Applies a margin of 1rem to the left side</div>
 <div class="mx-4">Applies a margin of 1rem to the right and left sides</div>
```
