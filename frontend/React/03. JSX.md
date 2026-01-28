# JSX

- JSX is a syntax extension for JavaScript that allows developers to write HTML-like markup inside JavaScript code. JSX
  improves readability and makes UI structure more intuitive.
- Under the hood, JSX is transpiled into React.createElement() calls, which React uses to build the Virtual DOM.

### 1. JSX: JavaScript XML (JSX Components)

- JSX (JavaScript XML) is a syntax extension letting you write HTML-like code in JS.
- It's transpiled to React.createElement() calls.
- In React 18, it supports fragments (<>) and new JSX transform (no import needed if configured).

- JSX Example
```jsx
function App() {
  return <h1>Hello JSX</h1>;
}

export default App;
```
- Behind the scenes
```js
React.createElement("h1", null, "Hello JSX");
```
```jsx
// It's just JavaScript!
const element = <h1>Hello, {user.name}</h1>;

// Multi-line with parentheses
const list = (
  <ul>
    {items.map((item) => (
      <li key={item.id}>{item.name}</li>
    ))}
  </ul>
);

// Fragments for multiple elements
const Component = () => (
  <>
    <Header />
    <MainContent />
    <Footer />
  </>
);
```

**Rules:**

- One root element per return (use fragments <>)
- className not class
- htmlFor not for
- Events: onClick not onclick
- l̥Always close tags: <img /> not <img>
- Javascript in {}
