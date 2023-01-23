
add_theme <- function(myplot, xtitle_size, title_size, legend_title_size)
{
  # xtitle_size = 6
  # title_size = 7
  # legend_title_size = 5
  myplot <- myplot + theme(axis.line = element_line(colour = 'black', size = 0.3),
                           axis.ticks.length = unit(0.1, "cm"),
                           axis.ticks = element_line(colour = "black", size = 0.2),
                           axis.title.x = element_blank(),
                           # axis.title.x = element_text(colour = "black",size = xtitle_size, family = "Arial"),
                           plot.title = element_text(hjust=0.5, size = title_size, family = "Arial", face="bold", margin=margin(b = 0.01, unit = "inch")),
                           axis.text.x = element_text(colour = "black",size = xtitle_size, family = "Arial"),
                           axis.title.y=element_blank(),
                           axis.text.y = element_text(colour = "black",size = title_size-1, family = "Arial"),
                           strip.text.x = element_text(size = xtitle_size, colour = "black", family = "Arial"), strip.background = element_blank(),
                           legend.text = element_text(size=legend_title_size, family = "Arial"),
                           legend.background = element_rect(fill = "transparent"),
                           panel.background = element_rect(fill = "transparent"),
                           legend.title = element_text(size=legend_title_size, family = "Arial"))#+scale_colour_brewer(palette = "Set2") #hjust=0.5, size = 9, family = "Arial"
}



#plot correlation heatmap
plot_corr_heatmap <- function(r,p, colname, rowname, savepath, wid, hei) 
{
  
  colnames(r) <- colname
  rownames(r) <- rowname
  colnames(p) <- colname
  rownames(p) <- rowname
  col<- colorRampPalette(c("blue", "white","red"))(20)
  tiff(file=savepath, width=wid, height=hei, res=300, units="in")
  corrplot(r, tl.srt=90,
           p.mat = p, sig.level = 0.05, insig = "blank", col = col, na.label=" ")
  # tl.col="black"， method = "number", 
  dev.off()
  
  
}
