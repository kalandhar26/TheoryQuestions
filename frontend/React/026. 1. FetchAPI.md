# Fetch API

- Imagine Fetch like sending a letter to a friend by mail—you tell it where to go (the URL), what to say (like GET or
  POST), and wait for a reply (the data). It's built right into your browser, so no extra apps needed, but you have to
  handle the "Did it arrive okay?" part yourself if something goes wrong.

## Professional definition:

- The Fetch API is a native JavaScript interface for making HTTP requests. It's promise-based, supports modern features
  like async/await, and works for GET, POST, PUT, DELETE, etc. Unlike older XMLHttpRequest, it's simpler but requires
  manual JSON parsing and error handling for non-2xx responses.

## PseudoCode:

```text
  textasync function makeRequest(url, options = {}) {
  try {
  const response = await fetch(url, options); // Send request
  if (!response.ok) throw new Error('Request failed'); // Check status
  const data = await response.json(); // Parse response
  return data;
  } catch (error) {
  console.error('Error:', error); // Handle errors
  }
  }

// Usage: GET
makeRequest('/api/users');

// POST
makeRequest('/api/users', {
method: 'POST',
headers: { 'Content-Type': 'application/json' },
body: JSON.stringify({ name: 'Alice' })
});
```

## Easy Code Example:

```jsx
jsximport React, { useState, useEffect } from 'react';

function UserList() {
const [users, setUsers] = useState([]);

useEffect(() => {
fetch('/api/users') // Simple GET request
.then(response => response.json())
.then(data => setUsers(data))
.catch(error => console.error('Fetch error:', error));
}, []);

return (
<ul>
{users.map(user => <li key={user.id}>{user.name}</li>)}
</ul>
);
}
```

## Complex Code Example:

```jsx
jsximport React, { useState, useEffect } from 'react';

function TodoApp() {
const [todos, setTodos] = useState([]);
const [newTodo, setNewTodo] = useState('');
const [loading, setLoading] = useState(false);

// Fetch all todos
useEffect(() => {
const fetchTodos = async () => {
setLoading(true);
try {
const response = await fetch('/api/todos', {
method: 'GET',
headers: { 'Authorization': 'Bearer token123' } // Custom header
});
if (!response.ok) {
throw new Error(`HTTP error! status: ${response.status}`);
}
const data = await response.json();
setTodos(data);
} catch (error) {
console.error('Failed to fetch todos:', error);
} finally {
setLoading(false);
}
};
fetchTodos();
}, []);

// Add a new todo
const addTodo = async () => {
if (!newTodo) return;
try {
const response = await fetch('/api/todos', {
method: 'POST',
headers: {
'Content-Type': 'application/json',
'Authorization': 'Bearer token123'
},
body: JSON.stringify({ text: newTodo, completed: false })
});
if (!response.ok) throw new Error('Failed to add todo');
const addedTodo = await response.json();
setTodos(prev => [...prev, addedTodo]);
setNewTodo('');
} catch (error) {
console.error('Add todo error:', error);
}
};

// Delete a todo
const deleteTodo = async (id) => {
try {
const response = await fetch(`/api/todos/${id}`, {
method: 'DELETE',
headers: { 'Authorization': 'Bearer token123' }
});
if (!response.ok) throw new Error('Failed to delete todo');
setTodos(prev => prev.filter(todo => todo.id !== id));
} catch (error) {
console.error('Delete todo error:', error);
}
};

if (loading) return <p>Loading todos...</p>;

return (
<div>
<input
value={newTodo}
onChange={e => setNewTodo(e.target.value)}
placeholder="New todo"
/>
<button onClick={addTodo}>Add Todo</button>
<ul>
{todos.map(todo => (
<li key={todo.id}>
{todo.text} {todo.completed ? '(Done)' : ''}
<button onClick={() => deleteTodo(todo.id)}>Delete</button>
</li>
))}
</ul>
</div>
);
}
```