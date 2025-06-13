import React from 'react';

function Header() {
  return (
    <div className="navbar bg-base-200">
      <div className="navbar-start">
        <label htmlFor="obs-drawer" className="btn btn-square btn-ghost lg:hidden">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" className="inline-block w-5 h-5 stroke-current">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
        </label>
        <div className="dropdown">
          <label tabIndex={0} className="btn btn-ghost">File</label>
          <ul tabIndex={0} className="dropdown-content z-[1] menu p-2 shadow bg-base-200 rounded-box w-52">
            <li><a>Settings</a></li>
            <li><a>Exit</a></li>
          </ul>
        </div>
        <div className="dropdown">
          <label tabIndex={1} className="btn btn-ghost">Edit</label>
          <ul tabIndex={1} className="dropdown-content z-[1] menu p-2 shadow bg-base-200 rounded-box w-52">
            <li><a>Preferences</a></li>
          </ul>
        </div>
        <div className="dropdown">
          <label tabIndex={2} className="btn btn-ghost">View</label>
          <ul tabIndex={2} className="dropdown-content z-[1] menu p-2 shadow bg-base-200 rounded-box w-52">
            <li><a>Fullscreen</a></li>
            <li><a>Docks</a></li>
          </ul>
        </div>
      </div>
    </div>
  );
}

export default Header;