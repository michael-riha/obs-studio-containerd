import React from 'react';

function SourceList({ sources, setSources }) {
  return (
    <div className="flex flex-col gap-2">
      <div className="flex justify-between mb-1">
        <span className="text-sm">Sources</span>
        <div className="flex">
          <button className="btn btn-xs btn-ghost">+</button>
          <button className="btn btn-xs btn-ghost">-</button>
        </div>
      </div>
      <ul className="menu bg-base-100 rounded-box w-full">
        {sources.map(source => (
          <li key={source.id}>
            <a>
              <div className="form-control">
                <label className="cursor-pointer label justify-start p-0">
                  <input type="checkbox" defaultChecked={source.visible} className="checkbox checkbox-xs" />
                  <span className="ml-2">{source.name}</span>
                </label>
              </div>
            </a>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default SourceList;