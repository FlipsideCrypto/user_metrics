import logo from './logo.svg';
import './App.css';

import {useState} from 'react';


function ActionButton() {
  const [count, setCount] = useState(0);
  const isResetVisible = count > 0 ? true : false;
  let resetButton;
  if (isResetVisible) {
    resetButton = <button onClick={() => setCount(0)}>
      Reset
    </button >
  }
  return (
    <>
      <button onClick={() => setCount(count + 1)}>
        Number of clicks: {count}
      </button >
      {resetButton}
    </>
  );
}

function App() {
  return (
    <ActionButton />
  );
}

export default App;
