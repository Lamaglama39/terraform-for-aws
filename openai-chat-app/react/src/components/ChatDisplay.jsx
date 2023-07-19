import React, { useEffect, useRef } from "react"; // 追加
import UserIcon from "../icon/animal_arupaka.png";
import SystemIcon from "../icon/ai_dance_character.png";

const ChatDisplay = ({ chatHistory }) => {
  const chatRef = useRef(null); // 追加

  // 最下部へのスクロール
  useEffect(() => {
    if (chatRef.current) {
      chatRef.current.scrollTop = chatRef.current.scrollHeight;
    }
  }, [chatHistory]); // chatHistoryの変更を監視

  return (
    <div className="chat" ref={chatRef}>
      {chatHistory.map((chat, index) => (
        <div key={index} className={`message ${chat.type}`}>
          <img
            src={chat.type === "user" ? UserIcon : SystemIcon}
            className="icon"
            alt="icon"
          />
          <div dangerouslySetInnerHTML={{ __html: chat.message }}></div>
        </div>
      ))}
    </div>
  );
};

export default ChatDisplay;
