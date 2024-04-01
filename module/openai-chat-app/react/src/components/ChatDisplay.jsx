import React, { useEffect, useRef } from "react";
import UserIcon from "../icon/animal_arupaka.png";
import SystemIcon from "../icon/ai_dance_character.png";

const ChatDisplay = ({ chatHistory }) => {
  const chatRef = useRef(null);

  // 最下部へのスクロール
  useEffect(() => {
    if (chatRef.current) {
      chatRef.current.scrollTop = chatRef.current.scrollHeight;

      // ふわっと出現する効果を適用
      const messages = chatRef.current.getElementsByClassName("message");
      for (const message of messages) {
        if (!message.classList.contains("show")) {
          // 一定時間後に.showクラスを追加する
          setTimeout(() => {
            message.classList.add("show");
          }, 100);
        }
      }
    }
  }, [chatHistory]);

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
