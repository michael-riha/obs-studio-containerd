import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './app/App';
import './app/App.css';  // This import should match the file location

const container = document.getElementById('root');
const root = createRoot(container);
root.render(<App />);