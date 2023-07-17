import UserIcon from "../icon/animal_arupaka.png"; // ユーザーアイコンのパス
import SystemIcon from "../icon/ai_dance_character.png"; // システムアイコンのパス

const ChatDisplay = ({ chatHistory }) => {
  return (
    <div className="chat">
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
