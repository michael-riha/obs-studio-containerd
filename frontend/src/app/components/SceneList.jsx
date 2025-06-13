import React from 'react';

function SceneList({ scenes, setScenes }) {
  return (
    <div className="flex flex-col gap-2 mb-4">
      <div className="flex justify-between mb-1">
        <span className="text-sm">Scenes</span>
        <div className="flex">
          <button className="btn btn-xs btn-ghost">+</button>
          <button className="btn btn-xs btn-ghost">-</button>
        </div>
      </div>
      <ul className="menu bg-base-100 rounded-box w-full">
        {scenes.map(scene => (
          <li key={scene.id}>
            <a className={scene.active ? 'active' : ''}>{scene.name}</a>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default SceneList;