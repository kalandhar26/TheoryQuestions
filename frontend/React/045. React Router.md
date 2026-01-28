# React Router

React Router is the most popular routing library for React that enables client-side navigation by mapping URLs to
components without full page reloads.

```jsx
import { BrowserRouter, Routes, Route, Link } from "react-router-dom";

function App() {
  return (
    <BrowserRouter>
      <Link to="/">Home</Link>
      <Link to="/about">About</Link>

      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
      </Routes>
    </BrowserRouter>
  );
}
```

# React Location

React Location is a modern, lightweight routing library focused on data-driven routing, performance, and type safety,
built by the creator of TanStack Query.

```jsx
import { ReactLocation, Router, Route } from "@tanstack/react-location";

const location = new ReactLocation();

const routes = [
  { path: "/", element: <Home /> },
  { path: "about", element: <About /> }
];

function App() {
  return (
    <Router location={location} routes={routes} />
  );
}
```

| Feature        | React Router | React Location |
|----------------|--------------|----------------|
| Popularity     | ⭐⭐⭐⭐⭐        | ⭐⭐             |
| Learning Curve | Easy         | Medium         |
| Data Loading   | Limited      | Built-in       |
| Type Safety    | Limited      | Strong         |
| Performance    | Good         | Excellent      |
| Community      | Huge         | Small          |

