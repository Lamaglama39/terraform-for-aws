import { useState, useEffect } from "react";

const ChatDisplay = ({ chatHistory }) => {
  return (
    <div
      style={{
        overflow: "auto",
        height: "calc(100vh - 100px)",
        marginBottom: "20px",
        display: "flex",
        flexDirection: "column",
      }}
    >
      {chatHistory.map((chat, index) => (
        <div key={index} className={`message ${chat.type}`}>
          {chat.message}
        </div>
      ))}
    </div>
  );
};

export default ChatDisplay;
